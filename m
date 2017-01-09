From: Juergen Gross <jgross@suse.com>
Subject: Re: [PATCH 2/3] xen: modify xenstore watch event interface
Date: Mon, 9 Jan 2017 08:12:36 +0100
Message-ID: <a80eb102-8b58-8744-2ce4-57f52437d1be@suse.com>
References: <20170106150544.10836-1-jgross@suse.com>
 <20170106150544.10836-3-jgross@suse.com>
 <c4a181ac-ca47-16bd-5b3d-ea25e413355f@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, roger.pau@citrix.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, netdev@vger.kernel.org
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4a181ac-ca47-16bd-5b3d-ea25e413355f@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/17 22:57, Boris Ostrovsky wrote:
> On 01/06/2017 10:05 AM, Juergen Gross wrote:
>> Today a Xenstore watch event is delivered via a callback function
>> declared as:
>>
>> void (*callback)(struct xenbus_watch *,
>>                  const char **vec, unsigned int len);
>>
>> As all watch events only ever come with two parameters (path and token)
>> changing the prototype to:
>>
>> void (*callback)(struct xenbus_watch *,
>>                  const char *path, const char *token);
>>
>> is the natural thing to do.
>>
>> Apply this change and adapt all users.
>>
>> Cc: konrad.wilk@oracle.com
>> Cc: roger.pau@citrix.com
>> Cc: wei.liu2@citrix.com
>> Cc: paul.durrant@citrix.com
>> Cc: netdev@vger.kernel.org
>>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
> 
> 
>>  
>> @@ -903,24 +902,24 @@ static int process_msg(void)
>>  	body[msg->hdr.len] = '\0';
>>  
>>  	if (msg->hdr.type == XS_WATCH_EVENT) {
>> -		msg->u.watch.vec = split(body, msg->hdr.len,
>> -					 &msg->u.watch.vec_size);
>> -		if (IS_ERR(msg->u.watch.vec)) {
>> -			err = PTR_ERR(msg->u.watch.vec);
>> +		if (count_strings(body, msg->hdr.len) != 2) {
>> +			err = -EINVAL;
> 
> xenbus_write_watch() returns -EILSEQ when this type of error is
> encountered so perhaps for we should return the same error here.

Not since 9a6161fe73bdd3ae4a1e18421b0b20cb7141f680. :-)

> 
> Either way
> 
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

Thanks,

Juergen
