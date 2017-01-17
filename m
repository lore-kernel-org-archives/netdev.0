From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v4 2/6] virtio_net: wrap rtnl_lock in test for calling
 with lock already held
Date: Tue, 17 Jan 2017 11:03:20 -0800
Message-ID: <587E6A78.6020901@gmail.com>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
 <20170115235947.28980.92147.stgit@john-Precision-Tower-5810>
 <20170117.115733.428297564258724055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35216 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdAQTDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:03:34 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so16775725pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:03:34 -0800 (PST)
In-Reply-To: <20170117.115733.428297564258724055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 08:57 AM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Sun, 15 Jan 2017 15:59:47 -0800
> 
>> @@ -2358,7 +2371,10 @@ static void remove_vq_common(struct virtnet_info *vi)
>>  	/* Free unused buffers in both send and recv, if any. */
>>  	free_unused_bufs(vi);
>>  
>> -	free_receive_bufs(vi);
>> +	if (rtnl_is_locked())
>> +		_free_receive_bufs(vi);
>> +	else
>> +		free_receive_bufs(vi);
>>  
>>  	free_receive_page_frags(vi);
>>  
> 
> This doesn't work.  rtnl_is_locked() doesn't tell if _you_ own the mutex, it
> just says that someone does.
> 
> So if we now execute this code without taking the RTNL lock just because some
> other thread of control holds it, we introduce a race.
> 

yeah this bit is junk. dang. Trying to get this locking right without duplicate
code or pushing around lock_me variables is getting tricky.

.John
