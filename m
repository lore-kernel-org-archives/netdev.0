From: David Johnson <dj@david-web.co.uk>
Subject: Re: Hardware bug or kernel bug?
Date: Mon, 16 Oct 2006 15:32:38 +0100
Message-ID: <200610161532.38663.dj@david-web.co.uk>
References: <20061013085605.GA1690@ff.dom.local> <200610131724.40631.dj@david-web.co.uk> <20061016102500.GA1709@ff.dom.local>
Reply-To: dj@david-web.co.uk
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:15829 "EHLO
	rutherford.zen.co.uk") by vger.kernel.org with ESMTP
	id S1750732AbWJPOcm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 10:32:42 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061016102500.GA1709@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 October 2006 11:25, Jarek Poplawski wrote:
>
> Was this lock-up effect visible during above 2.6.19-rc1 tests?

No, I've not seen anything in Linux other than the reboots, which are instant 
without any preceding lock-up.

> If not I'd try to continue linux debbuging:
> - is 2.6.19-rc1 working with "normal" config (use make oldconfig
> to "upgrade" .config),

With 2.6.19-rc1 and a normal config, I get the reboots as usual.

> - is 2.6.17 working with "minimal" config (use make oldconfig),

Yes.

> - changing one or two options at a time try to find which one makes
> the effect returns (acpi, smp...).

I've found the culprit - CPU Frequency Scaling.
With it enabled I get the reboots, with it disabled I don't. That's the same 
with every kernel version I've tried (2.6.19-rc1+rc2, 2.6.17.13 & Centos' 
2.6.9) The system was using the p4-clockmod driver and the ondemand governor.

I'm still not sure exactly what the problem is - the reboots only happen in 
the circumstances I've mentioned and are not triggered by changes in clock 
speed alone - but disabling cpufreq seems to make it go away...

Thanks for your help,
David.
