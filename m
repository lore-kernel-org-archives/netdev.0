From: Michal Zatloukal <myxal.mxl@gmail.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to
 detect link after resume from S3
Date: Sat, 30 Jun 2012 00:36:38 +0200
Message-ID: <CAKKZj2D-VVZF81=7-y+WtFGumzKJUfuaiB8k8X=BFXiXi0nfbg@mail.gmail.com>
References: <op.wgon84tw16tawo@esprimo>
	<20120629215840.GA21533@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:56189 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2F2Wgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 18:36:38 -0400
Received: by ghrr11 with SMTP id r11so3241994ghr.19
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2012 15:36:38 -0700 (PDT)
In-Reply-To: <20120629215840.GA21533@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, not a developer, but I assume you mean something like:
 if (!hw)
                return 0;

+        mdelay(800);
        /* Re-enable all clocks */
Right? In that case, I'm building the kernel now and should be able to
report by tomorrow.

MZ

On Fri, Jun 29, 2012 at 11:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> (maintainers Cced)
>
> Michal Zatloukal <myxal.mxl@gmail.com> :
> [7afe1845dd1e7c90828c942daed7e57ffa7c38d6 induced regression]
>> My uneducated guess is that by making the resume from S3 shorter, the
>> driver catches the hardware with its pants down and freaks out.
>> You can find all details/files (dmesg, lspci, dmidecode, config...)
>> collected by apport in the ubuntu bug linked above. Let me know if I
>> should supply any more info.
>> Note: Please CC me into replies, I'm not subscribed. Thank you.
>
> Can you workaround it by enforcing some mdelay() in sky2_resume before
> it does any real work ?
>
> --
> Ueimor
