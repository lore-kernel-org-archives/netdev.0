From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: Realtek 8111C transmit timed out
Date: Thu, 7 Aug 2008 00:50:24 +0200 (CEST)
Message-ID: <25916.84.245.32.19.1218063024.squirrel@secure.greenhost.nl>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
    <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
    <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
    <20080805214250.GA23226@electric-eye.fr.zoreil.com>
    <loom.20080806T144054-201@post.gmane.org>
    <20080806181235.GA17174@electric-eye.fr.zoreil.com>
    <25625.84.245.32.19.1218051465.squirrel@secure.greenhost.nl>
    <20080806195023.GA15747@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost1.greenhost.nl ([85.17.153.87]:58404 "EHLO
	smarthost1.samage.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbYHFWzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 18:55:31 -0400
In-Reply-To: <20080806195023.GA15747@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, August 6, 2008 21:50, Francois Romieu wrote:
> Indan Zupancic <indan@nul.nu> :
> [...]
>> "git log drivers/net/r8169.c" shows only two commits since May 11:
>
> $ git rev-list v2.6.26..v2.6.27-rc1 -- drivers/net/r8169.c
> 77332894c21165404496c56763d7df6c15c4bb09
> f887cce8de019bb32917789379af89ae4c0294ee
> 865c652d6be9929927cabdc54b137b7541eb6612
> 1087f4f4af302e6e2fa40dd741f306444d90bece
>
>> r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06
>>
>> r8169: multicast register update
>>
>> Then at May 11 comes:
>>
>> r8169: remove non-napi code
>>
>> But I think that was in 2.6.26 already.
>
> No. :o)

Oh...

I tried 2.6.27-rc2 with that patch reverted and NAPI disabled,
but that didn't work either, so it seems it's something a level
higher. (No way that that last patch could cause this...)

You said off-list that I may want to check if there is any aspm
related message in dmesg. Well, I get this:

  Pre-1.1 PCIe device detected, disable ASPM for 0000:00:1c.1.
  It can be enabled forcedly with 'pcie_aspm=force'

So I guess it's unlikely that it causes any problems, except
if the driver assumes it's always enabled. Booting with
pcie_aspm=force didn't change anything (though strangely
enough I still get the same message as above).

All in all I'll wait till rc3 and see how things are then.

Thank you for the help,

Indan


