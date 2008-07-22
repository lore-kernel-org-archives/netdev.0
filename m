From: jean-pascal billaud <billaud@vmware.com>
Subject: delayed ack timer, slow start and LRO
Date: Tue, 22 Jul 2008 14:44:05 -0700
Message-ID: <488654A5.5040905@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:58667 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752980AbYGVV44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:56:56 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.68.131])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 04D6640008
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 14:46:50 -0700 (PDT)
Received: from [10.20.114.98] (unknown [10.20.114.98])
	by mailhost3.vmware.com (Postfix) with ESMTP id 0CA9718001E5
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 14:46:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question related to the interaction between the delayed ack timer, slow start and LRO.

If the sender is doing a slow start, it is going to send one packet. The receiver's delayed ack timer is going to
kick in and when it expires it will send a ack.

Then the sender is going to send 2 packets now. LRO will aggregates them and the receiver's delayed ack timer is going
to kick in, hoping another packet will arrives which is not going to be the case. When the timer expires it is going to
send a ack.

The sender is now going to send 4 packets. LRO will aggregate them and the receiver's delayed ack timer is going to
kick in, hoping another packet will arrives which is not going to be the case. When the timer expires it is going to
send a ack.

The sender is now going to send ... So I am under the impression that due to the fact that LRO is aggregating packets,
the delayed ack timer will kick in every single time.

So how is this fixed in linux ? I believe that ABC implementation will fix this issue even if I am not completely sure
about that ?

Also as LRO adds some latency, it seems possible to me that the sender retransmission timer will expires before the 
delayed ack timer expires. In this case, how is this gonna work ? Is it possible that the sender will stay stuck in
its slow start trying to retransmit endlessly the same n packets ?

Can anyone help on that ?

thanks,

--jp

