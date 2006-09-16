From: "Xiaoliang (David) Wei" <davidwei79@gmail.com>
Subject: Re: TCP Pacing
Date: Fri, 15 Sep 2006 17:41:22 -0700
Message-ID: <7335583a0609151741g68a29d22j48fd9f48642d4b8a@mail.gmail.com>
References: <200609121958.22820.root@danielinux.net>
	 <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com>
	 <200609131018.40023.root@danielinux.net>
	 <200609131746.03679.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ian McDonald" <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	"Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:31956 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932263AbWIPAlX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 20:41:23 -0400
Received: by py-out-1112.google.com with SMTP id n25so4288200pyg
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 17:41:23 -0700 (PDT)
To: root@danielinux.net
In-Reply-To: <200609131746.03679.root@danielinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/13/06, Daniele Lacamera <root@danielinux.net> wrote:
> As Ian requested, some of the papers published about Pacing.
>

Hi Daniel,
     Thank you very much for the patch and the reference summary. For
the implementation and performance of pacing, I just have a few
suggestion/clarification/support data:

=46irst, in the implementation in the patch, it seems to me that the
paced gap is set to RTT/cwnd in CA_Open state. This might leads to
slower growth of congestion window. See our simulation results at
http://www.cs.caltech.edu/~weixl/technical/ns2pacing/index.html

If this pacing algorithm is used in a network with non-paced flows, it
is very likely to lose its fair share of bandwidth. So, I'd suggest to
use a pacing gap of RTT/max{cwnd+1, min{ssthresh, cwnd*2}} where
max{cwnd+1, min{ssthresh, cwnd*2}} is the expected congestion window
in *next RTT*. As shown in the our simulation results, this
modification will eliminate the slower growth problem.

> * Main reference:
> -----------------
>
> Amit Aggarwal, Stefan Savage, and Thomas Anderson.
> "Understanding the Performance of TCP Pacing".
> Proc. of the IEEE INFOCOM 2000 Conference on Computer Communications,
> March 2000, pages 1157 - 1165.

This main reference (Infocom2000) does not say pacing is always
improving. In fact, it says pacing might have poorer performance, in
term of average throughput, than non-paced flows in many cases. We
have some detailed study on the issue and our understanding are:
1. For loss based congestion control algorithm: if we care fairness
convergence, pacing helps; If we care aggregate/average throughput,
pacing does not help (and usually leads to lower average rate) unless
the bottleneck buffer size is extremely small.  This is due to the
fact that pacing usually introduces high loss synchronization rate in
the paced flows. We have a technical report at
http://www.cs.caltech.edu/~weixl/pacing/sync.pdf.

2. For delay based congestion control algorithm: pacing does always
help to eliminate the noise due to burstiness.

> Carlo Caini and Rosario Firrincieli,
> "TCP Hybla: a TCP enhancement for heterogeneous networks",
> INTERNATIONAL JOURNAL OF SATELLITE COMMUNICATIONS AND NETWORKING 2004=
;
> 22:547=96566

=46or TCP Hybla, we do have some simulation results to show that Hybla
introduces huge loss in start-up phase, if pacing is not deployed.
(Look for the figures of "hybla" at
http://www.cs.caltech.edu/~weixl/technical/ns2linux/index.html)

Thanks.

-David

--=20
Xiaoliang (David) Wei      Graduate Student, CS@Caltech
http://davidwei.org
***********************************************
