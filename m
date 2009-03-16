From: Pelle Svensson <pelle2004@hotmail.com>
Subject: RE: Intel 82567LM e1000e DHCP problem/question
Date: Mon, 16 Mar 2009 22:31:43 +0100
Message-ID: <BAY143-W2353DFECB11A239842C4C3B99B0@phx.gbl>
References: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
 <alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>
To: <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s35.bay0.hotmail.com ([65.54.246.235]:5341 "EHLO
	bay0-omc3-s35.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbZCPVbp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 17:31:45 -0400
In-Reply-To: <alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




----------------------------------------
> Date: Mon, 16 Mar 2009 11:38:49 -0700
> From: jesse.brandeburg@intel.com
> To: pelle2004@hotmail.com
> CC: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net
> Subject: Re: Intel 82567LM e1000e DHCP problem/question
>
> good idea to include e1000-devel@lists.sourceforge.net on these kinds=
 of
> requests.
>
>
> On Sun, 15 Mar 2009, Pelle Svensson wrote:
>> Is there any functionality inside the driver for DHCP request.
>> I see in the source that there is some kind of DHCP filter f the tx =
stream.
>> Can the drive issue DHCP request inside it self when the Cable is un=
plugged/plugged.
>
> short answer, the driver no, but the management firmware, maybe.
>
>> I'm tracing a DHCP fault.
>
> what kind of fault? Is the server faulting?

Yes the DHCP server cause the fault in a short answer.
In the long answer it depends on several things.=20
By the 2 kinds of request made by the client to the server,
it issued new IP adresses for each of the type of request rather freque=
ntly.
This ends up, after a while, with almost an idential faults as this bug=
=2E
https://bugzilla.redhat.com/show_bug.cgi?id=3D473658

>
>> When the net is brought down, ifdown eth0, the dhclient is killed.
>> Then when I unplugged/plugged the cable I get a DHCP request even th=
at
>> dhclient is down.
>>
>> Also the Wireshark format of the DHCP request are different.
>> Correct request includes from dhclient has:
>>> Option: (t=3D12,l=3D5) Host Name =3D "pc005"
>> Incorrect requests when dhclient is killed does not have above.
>
> you apparently have the Intel AMT firmware (ME aka Management Engine)
> enabled in your BIOS, you can try to configure it by hitting CTRL-P d=
uring
> post (pre-boot) or at the prompt where it says to hit CTRL-P to enter
> system management setup.
>
> The ME (management engine) firmware is trying to acquire its own dhcp
> address and will do so if the driver is either not loaded or not up.
>
> Once the driver is loaded the firmware may still try to acquire a sec=
ond
> dhcp address for the ME, depending on your configuration. This whole
> setup works a lot like IPMI, but generally the ME is not configurable=
 via
> IPMI interfaces.
>
> Hope this helps,
> Jes

Your assumption about the Intel AMT seems right!

Log Tracking DHCP Request when plugged net cable in:

- Power on and load Fedora -> No DHCP Request from BIOS until Desktop u=
p
- ifdown eth0 -> DHCP Request
- Restart Fedora -> DHCP Request during the hole Shutdown process
- Enter BIOS menu -> DHCP Request
- Boot up Fedora -> DHCP Request from BIOS until Desktop up

ifdown eth0 trigged the plugged net cable DHCP Request

I tried to hit Ctrl-P frequently during the boot process but it newer d=
isplay any


management setup. I'm running Fedora 10 on Lenovo T500 bios 1.20 (6FET5=
0WW).





Only AMT stuff I can find for Lenovo is related to Vista or XP, But tha=
t seems to


for the OS not the BIOS. Can I load the Windows stuff and turn the AMT =
DHCP

stuff off? I do have dual boot for XP on this PC.



/Thanks
Pelle





_________________________________________________________________
Dela foton p=E5 ett smidigt s=E4tt med Windows Live=99 Photos.
http://www.microsoft.com/windows/windowslive/products/photos.aspx