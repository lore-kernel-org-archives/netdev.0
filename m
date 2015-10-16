From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: correctly check failed allocation
Date: Fri, 16 Oct 2015 10:40:59 +0100
Message-ID: <5620C62B.4000001@citrix.com>
References: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
	<CAGoFzNdCef+tutWgabSahHqV0rkC9FdNpjrQEsxk8GMeBA0TKQ@mail.gmail.com>
 <20151016090521.GJ32638@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Yeongjin Jang <yeongjin.jang@gatech.edu>,
	Taesoo Kim <taesoo@gatech.edu>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, "Yun, Insu" <insu@gatech.edu>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>, Insu Yun <wuninsu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151016090521.GJ32638@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16/10/15 10:05, Wei Liu wrote:
> On Thu, Oct 15, 2015 at 02:02:47PM -0400, Insu Yun wrote:
>> I changed patch with valid format.
>>
>> On Thu, Oct 15, 2015 at 2:02 PM, Insu Yun <wuninsu@gmail.com> wrote:
>>
>>> Since vzalloc can be failed in memory pressure,
>>> writes -ENOMEM to xenstore to indicate error.
>>>
>>> Signed-off-by: Insu Yun <wuninsu@gmail.com>
>>> ---
>>>  drivers/net/xen-netback/xenbus.c | 6 ++++++
>>>  1 file changed, 6 insertions(+)
>>>
>>> diff --git a/drivers/net/xen-netback/xenbus.c
>>> b/drivers/net/xen-netback/xenbus.c
>>> index 929a6e7..56ebd82 100644
>>> --- a/drivers/net/xen-netback/xenbus.c
>>> +++ b/drivers/net/xen-netback/xenbus.c
>>> @@ -788,6 +788,12 @@ static void connect(struct backend_info *be)
>>>         /* Use the number of queues requested by the frontend */
>>>         be->vif->queues = vzalloc(requested_num_queues *
>>>                                   sizeof(struct xenvif_queue));
>>> +       if (!be->vif->queues) {
>>> +               xenbus_dev_fatal(dev, -ENOMEM,
>>> +                                "allocating queues");
>>> +               return;
>>>
>>
>> I didn't use goto err, because another error handling is not required
>>
> 
> It's recommended in kernel coding style to use "goto" style error
> handling. I personally prefer that to arbitrary return in function body,
> too.
> 
> It's not a matter of whether another error handling is required or not,
> it's about cleaner code that is easy to reason about and consistent
> coding style.

Using xenbus_dev_fatal(); return; throughout would be consistent and
easy to reason about.

Also, the goto err path should raise a fatal error (instead of
disconnecting).  I also note that failures in the xen_net_read_rate(),
xen_register_watchers() and read_xenbus_vif_flags() are also not handled.

David
