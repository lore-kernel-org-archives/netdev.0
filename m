From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] VSOCK: add loopback to virtio_transport
Date: Sat, 19 Nov 2016 19:14:15 -0800
Message-ID: <58311507.7070707@gmail.com>
References: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
 <20161119.220804.755313313976863187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cavery@redhat.com,
        imbrenda@linux.vnet.ibm.com, jhansen@vmware.com
To: David Miller <davem@davemloft.net>, stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33106 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbcKTDOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:14:30 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so24749667pgd.0
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 19:14:30 -0800 (PST)
In-Reply-To: <20161119.220804.755313313976863187.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-19 07:08 PM, David Miller wrote:
> From: Stefan Hajnoczi <stefanha@redhat.com>
> Date: Thu, 17 Nov 2016 15:49:23 +0000
> 
>> @@ -159,6 +199,10 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *pkt)
>>  		return -ENODEV;
>>  	}
>>  
>> +	if (le32_to_cpu(pkt->hdr.dst_cid) == vsock->guest_cid) {
>> +		return virtio_transport_send_pkt_loopback(vsock, pkt);
>> +	}
>> +
> 
> A single-statement basic block should get surrounding curly
> braces.
> 

Should _not_ get curly braces in case it wasn't obvious ;)
