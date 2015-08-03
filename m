From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 1/1] e1000: remove dead e1000_init_eeprom_params calls.
Date: Mon, 3 Aug 2015 16:07:48 -0700
Message-ID: <CAL3LdT6UmZ6x0bm--qQ3YQ2RM5SQjmgaQoa4GeQdEbxbQD9iBg@mail.gmail.com>
References: <20150714202311.GA5189@192-168-0-3.rdsnet.ro>
	<20150724214036.GA29524@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Joern Engel <joern@logfs.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33639 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbHCXHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 19:07:49 -0400
Received: by obdeg2 with SMTP id eg2so110501124obd.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 16:07:48 -0700 (PDT)
In-Reply-To: <20150724214036.GA29524@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 2:40 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> The device probe method e1000_probe calls e1000_init_eeprom_params
> itself so there's no reason to call it again from e1000_do_write_eeprom
> or e1000_do_read_eeprom.
>
> The sentence above assumes that e1000_init_eeprom_params is effective
> but it's mostly dependant on "hw->mac_type": safe as e1000_probe bails
> out early if it can't set mac_type (see e1000_init_hw_struct, then
> e1000_set_mac_type).
>
> Btw, if effective, the removed paths would had been deadlock prone when
> e1000_eeprom_spi was set:
> -> e1000_write_eeprom (takes e1000_eeprom_lock)
>    -> e1000_do_write_eeprom
>       -> e1000_init_eeprom_params
>          -> e1000_read_eeprom (takes e1000_eeprom_lock)
>
> (same narrative with e1000_read_eeprom -> e1000_do_read_eeprom etc.)
>
> As a final note, the candidate deadlock above can't happen in e1000_probe
> due to the way eeprom->word_size is set / tested.
>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>
> Untested. I have found it while looking at Joern's patch.
>
>  drivers/net/ethernet/intel/e1000/e1000_hw.c | 8 --------
>  1 file changed, 8 deletions(-)

Can you please send this to intel-wired-lan@lists.osuosl.org mailing
list?  That is the mailing list created/used for these patches.  It
also helps me out by adding your patch to our patchworks project for
patches against Intel wired drivers.

Thanks in advance, sorry for the delayed response, was on vacation last week.
