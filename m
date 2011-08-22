From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 19:58:43 +0200
Message-ID: <20110822175843.GC3294@nuttenaction>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gabriel Beddingfield <gabrbedd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:40585 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751174Ab1HVR6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 13:58:46 -0400
Content-Disposition: inline
In-Reply-To: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Gabriel Beddingfield | 2011-08-22 10:34:14 [-0500]:

>I'm having trouble with a particular server via HTTPS.  It appears
>that my local linux machines are sending incorrect ACK.  However, I
>don't have enough expertise to know for sure.
>
>Using wireshark, the server sends:
>
>    Transmission Control Protocol, Src Port: https (443), Dst Port:
>36015 (36015), Seq: 27658, Ack: 827, Len: 18
>
>Local machine replies:
>
>    Transmission Control Protocol, Src Port: 36015 (36015), Dst Port:
>https (443), Seq: 827, Ack: 27677, Len: 0
>
>It appears to me that the ACK is off-by-one (should have been 27676).

No, it is absolutely correct: ACK -> last seen Seq plus one (27658 + 18 + 1):

RFC 793:

    If the ACK control bit is set this field contains the value of the
		next sequence number the sender of the segment is expecting to
		receive.  Once a connection is established this is always sent.


Cheers, Hagen
