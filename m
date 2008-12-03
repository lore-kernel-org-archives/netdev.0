From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Subject: TCP default congestion control in linux should be newreno
Date: Wed, 3 Dec 2008 17:12:59 +0100
Message-ID: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
References: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:21526 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYLCQNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 11:13:01 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2530179fgg.17
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2008 08:12:59 -0800 (PST)
In-Reply-To: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we have added plots of cwnd at

http://c3lab.poliba.it/index.php/TCP_over_Hsdpa

in the case of newreno, wetwood+, bic/cubic.

basically the goodput is similar with all variants  but with
significantly larger packet losses and timeouts with bic/cubic. i am
pretty sure that this would happen with any algos -including h-tcp-
that makes the probing more aggressive leaving the van jacobson linear
phase.

westwood+ seems to "gain" on the side of rtt (i.e. less queueing)
becasue of the specific setting after congestion.

at this stage of research,  i think  that newreno should be made the
deafult stack in linux.


saverio

On Fri, Nov 28, 2008 at 12:09 PM, Douglas Leith <Doug.Leith@nuim.ie> wrote:
>
> A bit of delayed input to this thread on netdev ...
>
>> I'm not so sure about this logic, regardless of the algorithms
>> involved.
>>
>> H-TCP was never the default in any distribution or release that
>> I know of.  So it's real world exposure is effectively zero,
>> which is the same as the new CUBIC stuff.
>
>> They are effectively, therefore, equivalent choices.
>
> Not really.  At this stage HTCP has undergone quite extensive independent testing by a good few groups (Caltech, Swinburne, North Carolina etc).  Its also been independently implemented in FreeBSD by the Swinburne folks.  Its true it hasn't been default in linux, but it HTCP  been subject to *far* more testing than the new cubic algorithm which has had no independent testing at all to my knowledge.
>
> I'd also like to add some new input to the discussion on choice of congestion control algorithm in linux - and why it might be useful to evaluate alternatives like htcp.   Almost all of the proposals for changes to tcp (including cubic) have really slow convergence to fairness when new flows start up.   The question is then whether it matters e.g. whether it negatively impacts users.
>
> To try to get a handle on this, we took one set of measurements from a home DSL line over a live link (so hopefully representative of common user experience), the other from a the production link out of the hamilton institute (so maybe more like the experience of enterprise users).   Plots of our measurements are at
>
> http://www.hamilton.ie/doug/tina2.eps  (DSL link)
> http://www.hamilton.ie/doug/caltech.eps  (hamilton link)
>
> and also attached.
>
> We started one long-ish flow (mimicking incumbent flows) and then started a second shorter flow.  The plots show the completion time of the second flow vs its connection size.  If the incumbent flow is slow to release bandwidth (as we expect with cubic), we expect the completion time of the second flow to increase, and indeed this is what we see.
>
> What's particularly interesting is (i) the magnitude of the difference - completion times are consistently x2 with cubic vs htcp over many tests and (ii) that this effect is apparent not only on higher speed links (caltech.eps) but also on regular DSL links (tina2.eps - we took measurements from a home DSL line, so its not a sanitised lab setup or anything like that).
>
> As might be expected, the difference in completion times eventually washes out for long transfers, e.g for the DSL link the most pronounced difference is for 1MB connections (where there is about a x2 difference in times between cubic and htcp) but becomes less for longer flows.  The point is that most real flows are short however, so the performance with a 1MB size flow seems like it should be more important than the 10MB size performance.  For me the DSL performance is the more important one here since it affects so many people, and was quite surprising, although I can also reproduce similar results on our testbed so its not a weird corner case or anything like that.
>
> Wouldn't it be interesting to give h-tcp a go in linux to get wider feedback ?
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



--
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
Fax. +39 080 5963410
email:mascolo@poliba.it

http://www-dee.poliba.it/dee-web/Personale/mascolo.html
