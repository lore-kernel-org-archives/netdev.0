From: Baoquan He <bhe@redhat.com>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Mon, 31 Oct 2016 18:09:44 +0800
Message-ID: <20161031100944.GE7138@x1>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
 <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, dyoung@redhat.com
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51154 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754112AbcJaKJs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 06:09:48 -0400
Content-Disposition: inline
In-Reply-To: <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

On 10/26/16 at 12:31pm, Paul Menzel wrote:
> Baoquan, could you please fix this regression. My suggestion is, that you
> add the old code back, but check if the firmware has been loaded. If it
> hasn’t, load it again.
> 
> That way, people can update their Linux kernel, and it continues working
> without changing the initramfs, or anything else.

I checked code and this looks good to me. I can post a patch with this
change to upstream, see what maintainers and other reviewers say.

The thing is I don't understand quite well about your requirement. With
my understanding, you just didn't add bnx2 firmware into initramfs, but
later opening the interface can still request that firmware with "ifup
eth-xxx" command. Is that correct? If yes, requeting firmware twice in
probing path and opening path looks good.


However I am wondering what's your exact steps to do this. 

What I tried to do is I execute command "dracut --add-drivers bnx2 -f
/boot/initramfs-4.9.0-rc3+.img 4.9.0-rc3+" to build a new initramfs,
meanwhile make sure bnx2.ko is included, then uncompressed initramfs and
deleted bnx2 folder under lib/firmware/ of uncompressed initramfs. Then
pack them to be /boot/initramfs-4.9.0-rc3+.img and restart. I did saw
below failure message. But later how did you really make the bnx2
network interface up? Could you say it more specifically?

[    7.364186] bnx2: QLogic bnx2 Gigabit Ethernet Driver v2.2.6 (January 29, 2014)
[    7.371706] ACPI: PCI Interrupt Link [LN44] enabled at IRQ 44
[    7.378128] bnx2 0000:01:00.0: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
[    7.387619] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
[    7.387888] bnx2: probe of 0000:01:00.0 failed with error -2
[    7.388990] ACPI: PCI Interrupt Link [LN45] enabled at IRQ 45
[    7.389370] bnx2 0000:01:00.1: Direct firmware load for bnx2/bnx2-mips-09-6.2.1b.fw failed with error -2
[    7.389371] bnx2: Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
[    7.389475] bnx2: probe of 0000:01:00.1 failed with error -2

Thanks
Baoquan
