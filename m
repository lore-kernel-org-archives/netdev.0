From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network:
	concurrentlyrunsoftirqnetwork code on SMP
Date: Wed, 26 Sep 2007 09:26:37 -0400
Message-ID: <1190813197.4257.17.camel@localhost>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
	 <1190551422.4256.36.camel@localhost>
	 <007201c7ff89$d5db4cf0$d6ddfea9@JOHNYE1>
	 <20070925090333.11beebb2@freepuppy.rosehill>
	 <1190758944.4244.23.camel@localhost>
	 <004d01c7ffe2$b73fec20$ca8510ac@asimco>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, iceburgue@gmail.com
To: John Ye <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:62097 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbXIZN0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 09:26:49 -0400
Received: by rv-out-0910.google.com with SMTP id k20so2007169rvb
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 06:26:48 -0700 (PDT)
In-Reply-To: <004d01c7ffe2$b73fec20$ca8510ac@asimco>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-26-09 at 10:12 +0800, John Ye wrote:

> cpu hash (srcip + dstip) % nr_cpus, plus checking cpu balance periodically,
> shift cpu by an extra seed value?

That may work maybe even add ipproto as a 3rd tuple; experiments will
tell - you need to be able to generate a random enough traffic pattern.
For example if the traffic pattern is always for your local host the
dstip may not be useful to the hash. 
You could always try the hash tests outside first; look at some of the
jenkins hashes in the kernel

> __do_IRQ has a tendency to collect same IRQ on different CPUs into one CPU
> when NIC is busy(by IRQ_PENDING & IRQ_INPROGRESS control skill). so,
> dispatch the load to SMP here may be good thing(?).

possibly. Or you may wanna tie the NIC IRQ to a CPU. 

cheers,
jamal


