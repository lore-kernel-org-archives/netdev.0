From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Sun, 24 Jan 2010 15:40:31 +0100
Message-ID: <4B5C5BDF.6020001@grandegger.com>
References: <1264039999-25731-1-git-send-email-agust@denx.de> <20100121.012235.161201297.davem@davemloft.net> <4B5871F2.9090005@grandegger.com> <201001231023.14372.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	wd@denx.de, dzu@denx.de, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, agust@denx.de, kosmo@semihalf.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45048 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab0AXOln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 09:41:43 -0500
In-Reply-To: <201001231023.14372.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Thursday 21 January 2010, Wolfgang Grandegger wrote:
>> The major problem that Anatolij tries to solve are the different
>> register layouts of the supported SOCs, MPC52xx and MPC8xx. They use the
>> same registers but at different offsets. Therefore we cannot handle
>> this with a single "fec_t" struct to allow building a single kernel
>> image. Instead it's handled by filling a table with register addresses:
>>
>>         if (of_device_is_compatible(ofdev->node, "fsl,mpc5121-fec")) {
>>                 fep->fec.fec_id = FS_ENET_MPC5121_FEC;
>>                 fec_reg_mpc5121(ievent);
>>                 fec_reg_mpc5121(imask);
>>                 ...
>>         } else {
>>                 fec_reg_mpc8xx(ievent);
>>                 fec_reg_mpc8xx(imask);
>>                 ...
>>         }
>>
>> Do you see a more clever solution to this problem? Nevertheless, the
>> code could be improved by using "offsetof", I think.
> 
> Is there any chance of building a kernel that runs on both mpc8xx and
> mpc5121? AFAIK, the 5121 is built on a 6xx core which is fundamentally
> incompatible with 8xx due to different memory management etc.
> 
> Since this makes it all a compile-time decision, it should be solvable
> with a very small number of carefully placed #ifdef in the header files
> an no runtime detection at all.
> 
> Obviously this approach would not work for drivers that want to be portable
> across different register layouts on otherwise compatible platforms.

You are probably right and your proposal would likely result in more
transparent (less ugly) code. There has been some discussion about
unifying FEC drivers when the patches (with the same subject) have been
submitted for the first time in May last year, but it was not about 512x
and 8xx, IIRC.

Wolfgang.




