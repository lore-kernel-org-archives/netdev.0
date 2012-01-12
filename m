From: Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
Date: Thu, 12 Jan 2012 13:37:29 -0600
Message-ID: <4F0F3679.7090304@opengridcomputing.com>
References: <20120112064722.GB2408@elgon.mountain>   <20120112162141.GC6563@fieldses.org>  <1326395759.6198.7.camel@lade.trondhjem.org>  <4F0F3380.4000406@opengridcomputing.com> <1326396510.6198.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1326396510.6198.12.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1/12/12 1:28 PM, Trond Myklebust wrote:
> On Thu, 2012-01-12 at 13:24 -0600, Tom Tucker wrote:
>> On 1/12/12 1:15 PM, Trond Myklebust wrote:
>>> On Thu, 2012-01-12 at 11:21 -0500, J. Bruce Fields wrote:
>>>> On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
>>>>> Sparse complains because arg_ch->rs_length is declared as network
>>>>> endian but we're treating it as CPU endian.
>>>> This looks like it would actually change behavior on a little endian
>>>> architecture, so how did this work before?
>>>>
>>>>>  From some quick grepping, I see assignments both of the form
>>>> 	...rs_length = ntohl(...)
>>>>
>>>> and
>>>>
>>>> 	...rs_length = htonl(...)
>>>>
>>>> but only see one declaration for a field named rs_length.
>>>>
>>>> So my best guess would be that the code is ugly but working as is, and
>>>> needs cleanup by someone who knows how this field was intended to be
>>>> used.
>>> It looks to me as if rs_handle and rs_offset are being similarly abused.
>>> Basically, we need a serious clean up in svc_rdma_marshall.c to separate
>>> out those variables that are in XDR-encoded form and those that are not.
>>>
>> The abuse is taking place because the marshal/unmarshall is being done
>> in-place and it seemed wasteful at the time to add a chunk of memory to
>> preserve the aesthetic. A union would 'work', but you still wouldn't
>> 'know' whether the data was NBO or not by where it was -- which seems like
>> the intent of the __beXX in the first place.
> These are not variables that are used in hundreds of different places:
> why not just do the conversion from big-endian to cpu-endian when you
> actually need to use them?

That would work fine actually. At the time, I was trying to put all that 
marshalling logic in that one file and reuse the already present 
client-side header file that copies that stuff when it decodes it.

I'll dig around a little bit and see what might be the simplest way to 
clean this up.

Tom


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
