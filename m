From: Luca De Cicco <ldecicco@gmail.com>
Subject: Fw: Fwd: [RFC] tcp: make H-TCP the default congestion control
Date: Mon, 1 Dec 2008 23:20:10 +0100
Message-ID: <20081201232010.08738445@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saverio Mascolo <saverio.mascolo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Douglas Leith <Doug.Leith@nuim.ie>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:54053 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbYLAWVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:21:20 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1414525nfc.21
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2008 14:21:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------- Forwarded message ----------
From: Saverio Mascolo <saverio.mascolo@gmail.com>
Date: Mon, Dec 1, 2008 at 8:13 PM
Subject: Re: [RFC] tcp: make H-TCP the default congestion control
To: Douglas Leith <Doug.Leith@nuim.ie>
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
Stephen Hemminger <shemminger@vyatta.com>


dear all,

we have tested newreno (only ietf standard), bic (linux default), cubic
and westwood+ over commercial hsdpa card. we run 3000 experiments (down
and up links).
main results were:
1. similar downlink goodputs but with much more timeouts and packet loss
ratio when using bic/cubic (3 times timeouts and 2 times packet loss
ratio) 2. larger rtt experienced when using bic/cubic

more details can be found at:

http://c3lab.poliba.it/index.php/TCP_over_Hsdpa

saverio


On Fri, Nov 28, 2008 at 12:09 PM, Douglas Leith <Doug.Leith@nuim.ie>
wrote:

> A bit of delayed input to this thread on netdev ...
>
>  I'm not so sure about this logic, regardless of the algorithms
>> involved.
>>
>> H-TCP was never the default in any distribution or release that
>> I know of.  So it's real world exposure is effectively zero,
>> which is the same as the new CUBIC stuff.
>>
>
>  They are effectively, therefore, equivalent choices.
>>
>
> Not really.  At this stage HTCP has undergone quite extensive
> independent testing by a good few groups (Caltech, Swinburne, North
> Carolina etc).  Its also been independently implemented in FreeBSD by
> the Swinburne folks.  Its true it hasn't been default in linux, but
> it HTCP  been subject to *far* more testing than the new cubic
> algorithm which has had no independent testing at all to my knowledge.
>
> I'd also like to add some new input to the discussion on choice of
> congestion control algorithm in linux - and why it might be useful to
> evaluate alternatives like htcp.   Almost all of the proposals for
> changes to tcp (including cubic) have really slow convergence to
> fairness when new flows start up.   The question is then whether it
> matters e.g. whether it negatively impacts users.
>
> To try to get a handle on this, we took one set of measurements from
> a home DSL line over a live link (so hopefully representative of
> common user experience), the other from a the production link out of
> the hamilton institute (so maybe more like the experience of
> enterprise users).   Plots of our measurements are at
>
> http://www.hamilton.ie/doug/tina2.eps  (DSL link)
> http://www.hamilton.ie/doug/caltech.eps  (hamilton link)
>
> and also attached.
>
> We started one long-ish flow (mimicking incumbent flows) and then
> started a second shorter flow.  The plots show the completion time of
> the second flow vs its connection size.  If the incumbent flow is
> slow to release bandwidth (as we expect with cubic), we expect the
> completion time of the second flow to increase, and indeed this is
> what we see.
>
> What's particularly interesting is (i) the magnitude of the
> difference - completion times are consistently x2 with cubic vs htcp
> over many tests and (ii) that this effect is apparent not only on
> higher speed links (caltech.eps) but also on regular DSL links
> (tina2.eps - we took measurements from a home DSL line, so its not a
> sanitised lab setup or anything like that).
>
> As might be expected, the difference in completion times eventually
> washes out for long transfers, e.g for the DSL link the most
> pronounced difference is for 1MB connections (where there is about a
> x2 difference in times between cubic and htcp) but becomes less for
> longer flows.  The point is that most real flows are short however,
> so the performance with a 1MB size flow seems like it should be more
> important than the 10MB size performance. For me the DSL performance
> is the more important one here since it affects so many people, and
> was quite surprising, although I can also reproduce similar results
> on our testbed so its not a weird corner case or anything like that.
>
> Wouldn't it be interesting to give h-tcp a go in linux to get wider
> feedback ?
>
> Doug
>
>
>
>
>
>
>
>
>
>
>
>
>
>


-- 
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
Fax. +39 080 5963410
email:mascolo@poliba.it <email%3Amascolo@poliba.it>

http://www-dee.poliba.it/dee-web/Personale/mascolo.html


=================================
This message may contain confidential and/or legally privileged
information. If you are not the intended recipient of the message,
please destroy it. Any unauthorized dissemination, distribution, or
copying of the material in this message, and any attachments to the
message, is strictly forbidden.



-- 
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
Fax. +39 080 5963410
email:mascolo@poliba.it <email%3Amascolo@poliba.it>

http://www-dee.poliba.it/dee-web/Personale/mascolo.html


=================================
This message may contain confidential and/or legally privileged
information. If you are not the intended recipient of the message,
please destroy it. Any unauthorized dissemination, distribution, or
copying of the material in this message, and any attachments to the
message, is strictly forbidden.


-- 
Luca De Cicco, PhD
Politecnico di Bari (Italy)
http://c3lab.poliba.it/index.php/LDC

