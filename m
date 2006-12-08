From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Fri, 8 Dec 2006 19:56:14 +0100
Message-ID: <200612081956.14158.IvDoorn@gmail.com>
References: <200612031919.05228.IvDoorn@gmail.com> <200612031339.28148.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:39877 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761146AbWLHS4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 13:56:21 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1210384nfa
        for <netdev@vger.kernel.org>; Fri, 08 Dec 2006 10:56:20 -0800 (PST)
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612031339.28148.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 03 December 2006 19:39, Michael Wu wrote:
> On Sunday 03 December 2006 13:19, Ivo van Doorn wrote:
> > rt2400pci, rt2500pci and rt61pci share exactly the
> > same code for the eeprom reading. The only difference
> > is that rt61pci has a slightly different register reading
> > approach. In any case we have a lot of duplicate code.
> > Create a new module eeprom_93cx6 inside the rt2x00 folder
> > and make rt2x00 use that.
> Interesting. adm8211 has code to read 93C66 and 93C46 eeproms, and it looks 
> similar, albeit smaller and simpler, to your 93cx6 reading code. However, it 
> looks like your new eeprom reading code is general enough for adm8211 to use 
> too. I'll have to try it..

I have checked the adm80211 code as well, it seems to behave quite the same,
with the most notable difference the fact that adm80211 writes the READ_OPCODE
and the word index within a single command, while in eeprom_93cx6 this is
split into 2 seperate write commands.
I have not yet tested the exact impact for rt2x00 devices when they would combine
the write commands, but if that has no impact (or the adm80211 suffers no impact
when the write commands are being split) then rt2x00 and adm80211 could indeed
share the eeprom_93cx6 module.
If eeprom_93cx6 is moved to the /lib folder of the kernel, should it be approved by
a different maintainer first?

Ivo
