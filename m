From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Tue, 15 Jan 2008 23:32:54 +0100
Message-ID: <20080115223254.GB2680@ami.dom.local>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:9947 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204AbYAOW3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 17:29:07 -0500
Received: by nf-out-0910.google.com with SMTP id g13so10240nfb.21
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 14:29:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 12:46:02AM +0300, slavon@bigtelecom.ru wrote:
...
> Hmmm... i found way to fix this for me... but its not look good
>
> Scheme look like:
> Root - prio bands 3 priomap 0 0 0 0 ....
> --- Class 1
> --- Class 2
> -------- Copy of all table (Last this qdisc be root)
> --- Class 3
> -------- Copy of all table (Last this qdisc be root)
>
> 2. Add filter to root - flowid all packets to class 2
> 3. Delete qdisc at class 3
> 4. Create all table on class 3 (~20k qdiscs and 20k classes)
> 5. Replace filter on root - flowid all packets to class 3
> 6. If need update go to step 3, but use class 2
>
> All work good... and packets not dropeed =)
> But i have above 45 k classes and qdiscs.... After some time i will need 
> patch to up max qdisc and classes more then 65k (> 0xfffe) =)))
> Also i have very bad TC commands performance then i have more then 10k rules.

Right! I get your idea (not all details...), and this really shows
there is needed something simpler for this. 

Thanks,
Jarek P.
