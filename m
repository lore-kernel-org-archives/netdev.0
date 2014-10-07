From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net v2 3/8] net/fsl_pq_mdio: Replace spin_event_timeout() with
 arch independent
Date: Tue, 7 Oct 2014 08:12:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174C5BAC@AcuExch.aculab.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
 <1412667875-18225-4-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: 'Claudiu Manoil' <claudiu.manoil@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40547 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753092AbaJGIOL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 04:14:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00333-01 for <netdev@vger.kernel.org>;
 Tue,  7 Oct 2014 09:14:02 +0100 (BST)
In-Reply-To: <1412667875-18225-4-git-send-email-claudiu.manoil@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel. 
> spin_event_timeout() is PPC dependent, use an arch independent
> equivalent instead.

I think you should white a local function/#define that expands to spin_event_timeout()
on ppc and to the code below you are substituting on other architectures.

>  	/* Wait for the transaction to finish */
> -	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
> -				    MIIMIND_BUSY), MII_TIMEOUT, 0);
> +	timeout = MII_TIMEOUT;
> +	while ((ioread32be(&regs->miimind) & MIIMIND_BUSY) && timeout) {
> +		cpu_relax();
> +		timeout--;
> +	}

	David
