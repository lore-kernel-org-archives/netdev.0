From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: IPV4: Enable IP_ID sequencing for all traffic (inquiring mindswant to know why its set to zero)
Date: Wed, 16 Jul 2008 14:16:49 -0700
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A104AFDAA4@XCH-NW-7V2.nw.nos.boeing.com>
References: <487E4A6B.6040103@linux-foundation.org><20080716.133048.201600858.davem@davemloft.net><487E5C89.7050005@hp.com> <20080716.140100.20638484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <cl@linux-foundation.org>, <dlstevens@us.ibm.com>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:45143 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755112AbYGPVej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:34:39 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080716.140100.20638484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 >-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Wednesday, July 16, 2008 2:01 PM
>To: rick.jones2@hp.com
>Cc: cl@linux-foundation.org; dlstevens@us.ibm.com; 
>netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>Subject: Re: IPV4: Enable IP_ID sequencing for all traffic 
>(inquiring mindswant to know why its set to zero)
>
>From: Rick Jones <rick.jones2@hp.com>
>Date: Wed, 16 Jul 2008 13:39:37 -0700
>
>> I have vague recollections of wanting to avoid (then) locks on the 
>> increment in the non-fragmented paths, assertions that 
>covering cases 
>> like intermediate devices ignoring DF and fragmenting anyway didn't 
>> warrant concern etc.
>
>Partially, yes.
>
>If you look, we do increment the ID for TCP connections which will
>be setting IP_DF, but we allocate such IDs in a socket-local manner
>which keeps these allocations from depleating the real ID cache
>for that destination.
>
>This is legal because when IP_DF is set, the IDs serve no purpose.

The other implied use for IP_ID is as a uniquifier for
duplicate packet detection (DPD), e.g., to detect routing
loops in the network. But, 16 bits doesn't give sufficient
uniqueness for today's data rates anway, so flooding-based
protocols like Simplified Multicast Forwarding (SMF) really
can't use IP_ID by itself for that purpose.

SEAL extends the IP_ID to 32 bits. With 32 bits, it makes
sense to set it as monotonically-incrementing for every
packet out since a network-based DPD mechanism could
potentially make use of it. Also, 32 bits avoids the ID
wraparound issue such that a segmentation and reassembly
mechanism can be used even at high data rates.

SEAL is specified in 'draft-templin-seal', and is also
implemented at:

  http://osprey67.com/seal

This is linux kernel code, but it is not yet ready to be
submitted to netdev. It would be good to get some extra
eyes on the code to get some independent verification
testing and to weed out any bugs. If anyone is interested
in checking it out, please let me know.

Thanks - Fred
fred.l.templin@boeing.com 

>We had to do this because TCP header compression, used by SLIP et
>al., depends upon the ID value incrementing.
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
