From: Michal Zatloukal <myxal.mxl@gmail.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to
 detect link after resume from S3
Date: Sat, 30 Jun 2012 13:21:34 +0200
Message-ID: <CAKKZj2DFS8BkinneV-2tOPs2tjOjC1qhgekzf3wLsT4HSmaHOw@mail.gmail.com>
References: <op.wgon84tw16tawo@esprimo>
	<20120629215840.GA21533@electric-eye.fr.zoreil.com>
	<CAKKZj2D-VVZF81=7-y+WtFGumzKJUfuaiB8k8X=BFXiXi0nfbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:50154 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615Ab2F3LVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 07:21:36 -0400
Received: by lbbgm6 with SMTP id gm6so5742182lbb.19
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 04:21:35 -0700 (PDT)
In-Reply-To: <CAKKZj2D-VVZF81=7-y+WtFGumzKJUfuaiB8k8X=BFXiXi0nfbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, that didn't help.The 800-ms delay I intoduced also showed up in
dmesg AFTER reading all the ffs:

[   52.890768] sky2 0000:04:00.0: eth0: disabling interface
[   55.768112] sky2 0000:04:00.0: PME# enabled
[   55.768118] sky2 0000:04:00.0: wake-up capability enabled by ACPI
[   55.924104] PM: late suspend of drv:sky2 dev:0000:04:00.0 complete
after 156.048 msecs
[   56.236280] sky2 0000:04:00.0: Refused to change power state, currently in D3
[   56.236288] sky2 0000:04:00.0: restoring config space at offset 0xf
(was 0xffffffff, writing 0x10a)
[   56.236292] sky2 0000:04:00.0: restoring config space at offset 0xe
(was 0xffffffff, writing 0x0)
[   56.236297] sky2 0000:04:00.0: restoring config space at offset 0xd
(was 0xffffffff, writing 0x48)
[   56.236301] sky2 0000:04:00.0: restoring config space at offset 0xc
(was 0xffffffff, writing 0x0)
[   56.236305] sky2 0000:04:00.0: restoring config space at offset 0xb
(was 0xffffffff, writing 0x110f1734)
[   56.236310] sky2 0000:04:00.0: restoring config space at offset 0xa
(was 0xffffffff, writing 0x0)
[   56.236314] sky2 0000:04:00.0: restoring config space at offset 0x9
(was 0xffffffff, writing 0x0)
[   56.236318] sky2 0000:04:00.0: restoring config space at offset 0x8
(was 0xffffffff, writing 0x0)
[   56.236323] sky2 0000:04:00.0: restoring config space at offset 0x7
(was 0xffffffff, writing 0x0)
[   56.236327] sky2 0000:04:00.0: restoring config space at offset 0x6
(was 0xffffffff, writing 0x3001)
[   56.236331] sky2 0000:04:00.0: restoring config space at offset 0x5
(was 0xffffffff, writing 0x0)
[   56.236335] sky2 0000:04:00.0: restoring config space at offset 0x4
(was 0xffffffff, writing 0xf8000004)
[   56.236340] sky2 0000:04:00.0: restoring config space at offset 0x3
(was 0xffffffff, writing 0x10)
[   56.236344] sky2 0000:04:00.0: restoring config space at offset 0x2
(was 0xffffffff, writing 0x2000014)
[   56.236348] sky2 0000:04:00.0: restoring config space at offset 0x1
(was 0xffffffff, writing 0x100507)
[   56.236352] sky2 0000:04:00.0: restoring config space at offset 0x0
(was 0xffffffff, writing 0x436311ab)
[   56.241868] sky2 0000:04:00.0: wake-up capability disabled by ACPI
[   56.241872] sky2 0000:04:00.0: PME# disabled
[   57.035970] sky2 0000:04:00.0: ignoring stuck error report bit
[   57.035993] PM: resume of drv:sky2 dev:0000:04:00.0 complete after
794.124 msecs
[   58.421169] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421174] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421178] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421181] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421184] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421187] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421190] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421193] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421196] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421199] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421203] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421206] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421208] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421212] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421214] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421217] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421220] sky2 0000:04:00.0: eth0: phy I/O error
[   58.421348] sky2 0000:04:00.0: eth0: enabling interface

MZ

On Sat, Jun 30, 2012 at 12:36 AM, Michal Zatloukal <myxal.mxl@gmail.com> wrote:
> Sorry, not a developer, but I assume you mean something like:
>  if (!hw)
>                 return 0;
>
> +        mdelay(800);
>         /* Re-enable all clocks */
> Right? In that case, I'm building the kernel now and should be able to
> report by tomorrow.
>
> MZ
>
> On Fri, Jun 29, 2012 at 11:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>> (maintainers Cced)
>>
>> Michal Zatloukal <myxal.mxl@gmail.com> :
>> [7afe1845dd1e7c90828c942daed7e57ffa7c38d6 induced regression]
>>> My uneducated guess is that by making the resume from S3 shorter, the
>>> driver catches the hardware with its pants down and freaks out.
>>> You can find all details/files (dmesg, lspci, dmidecode, config...)
>>> collected by apport in the ubuntu bug linked above. Let me know if I
>>> should supply any more info.
>>> Note: Please CC me into replies, I'm not subscribed. Thank you.
>>
>> Can you workaround it by enforcing some mdelay() in sky2_resume before
>> it does any real work ?
>>
>> --
>> Ueimor
