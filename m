From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 21:38:20 -0500
Message-ID: <4589F39C.7010201@gentoo.org>
References: <20061220042648.GA19814@srcf.ucam.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221011209.GA32625@srcf.ucam.org> <200612202105.31093.flamingice@sourmilk.net> <20061221021832.GA723@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161159AbWLUChi@vger.kernel.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
In-Reply-To: <20061221021832.GA723@srcf.ucam.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Garrett wrote:
>> In order to scan, we need to have the radio on and we need to be able to send 
>> and receive. What are you gonna turn off?
> 
> The obvious route would be to power the card down, but come back up 
> every two minutes to perform a scan, or if userspace explicitly requests 
> one. Would this cause problems in some cases?

I don't think it makes sense. For zd1211 the power consumption and heat 
emission goes up considerably when the interface is brought up (radio 
on, interrupts enabled, etc), and this is also a relatively long 
operation in terms of duration needed to bring the interface up and 
down. A scanning operation requires radio on, interrupts enabled, lots 
of register reading, RF calibration, RX/TX ringbuffers allocation, etc.

I don't think that supporting scanning when the interface is supposed to 
be disabled is sensible. If you want to scan, you are simply sending and 
receiving frames, it's no different from having the interface up and 
sending/receiving data frames.

There are additional implementation problems: scanning requires 2 
different ioctl calls: siwscan, then several giwscan. If you want the 
driver to effectively temporarily bring the interface up when userspace 
requests a scan but the interface was down, then how does the driver 
know when to bring it down again?

Daniel
