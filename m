From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v3)
Date: Sat, 10 Feb 2007 12:25:27 -0200
Message-ID: <20070210142527.GB3814@dmt.wfacil.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:34586 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932289AbXBJO3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Feb 2007 09:29:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here goes an updated patch of the Marvell Libertas 8388 802.11 USB
driver, addressing pretty much all comments from Arnd (the remaining
ones are listed in TODO entry below).

Diff can be found at
http://dev.laptop.org/~marcelo/libertas-8388-10022007.patch

Please review.

TODO:
-  In places where you use variables that are strictly little-endian,
it would be nice to use the __le32/__le16 types instead of u32/u16.
- Convert chan_freq_power/region_cfp_table to generic code, if possible.

Changes since v2:

- remove unused "Command Processing States and Options" defines
- remove unused HostCmd_DELAY_* defines
- remove unused DEFAULT_CHANNEL_* definitions
- remove changelog from host.h
- remove unused Marvell specific OIDs from host.h
- remove unused HostCmd_CMD_NONE from host.h
- remove changelog from all files
- remove wlan_ prefix from files
- remove usage of UTF8 character from LICENSE file
- remove unused HostCmd_DS_EEPROM_UPDATE structure
- remove unused code from 11d.h
- convert 11d.{c,h} from SillyCaps to kernel-style and remove
- convert {rx,tx}.c from SillyCaps to kernel-style
- use shared ieee80211_hdr_4addr instead of libertas_ieee80211_hdr
- ioctl.c needs to #include <net/ieee80211.h>
- use generic ARRAY_SIZE instead of self-defined macro
- remove unused defines from defs.h
- convert defs.h to kernel-style and remove unused code
- get rid of unnecessary ENTER/EXIT in cmd related fn's, random cleanups
- get rid of struct ethii_hdr, use generic struct ethhdr def.
- remove unused defines from host.h
- remove unused SDIO_HEADER_LEN define
- get rid of WLAN_STATUS_SUCCESS/FAILURE/NOT_ACCEPTED
- use BootCMDStr on if_usb_issue_boot_command stack
- increase nr_cmd_pending max value warning from 32 to 128
- remove reassociation code
- HostCmd_DS_802_11_ASSOCIATE_RSP struct requires no packed attr.
- reorder struct WLAN_802_11_KEY to avoid padding
- get rid of empty command response handlers in cmdresp.c
- replace (-ENOMEM) with -ENOMEM in if_usb_prob()
- convert HostCmd_DS_802_11_AFC to anonymous union/struct
- do not use extern declarations in .c files
- get rid of dynamic wlan_add_card/remove_card
- remove unnecessary/misleading commentary from if_usb.c
- usb_int_cause should be a per-device variable
- move bootcmdresp inside if_usb_receive_fwload stack
- reorganize if_usb.c
- remove unused declarations from if_usb.h
- cleanup sbi.h
- get rid of ASSERT, use WARN_ON
- convert printk statements to lbs_dev_xxx
- libertas_mpp_{get,set} should be static
- wake_pending_cmdnodes should be static
- mark WEXT local handlers as static
- do not set data.pointer in libertas_send_iwevcustom_event
- mark local functions as static in ethtool.c
- mark local functions from debugfs.c as static
- fix sparse warnings in cmdresp.c
- fix 11d.c and 11d.h signedness issues
- remove unused ioctl code
- ioctl.c using plain integer as NULL pointer
- remove unused WLAN_SETCONF_GETCONF ioctl
- remove useless ENTRY/LEAVE pairs from if_usb.c
- remove useless ENTRY/LEAVE pairs from 11d.c
- remove useless commentary from cmd.c
- readd version.h
- get rid of HandleDisconnectEvent()
- remove useless commentary from cmd.c
- cleanup fw.c commentary and ENTER/EXIT points
- remove useless commentary from ioctl.c
- remove useless commentary from join.c, assorted cleanups
- remove useless commentary from main.c
- remove useless commentary from {tx,rx}.c
- remove useless commentary from wext.c
- remove mention to reassoc code in README
- remove mention to getcis from README
- remove unused definitions from fw.h
- remove unused definitions from host.h
- no need for dynamic allocation of URB callback private data
- remove unused ASSOC_RSP_BUF_SIZE definition from join.h
- CmdCtrlNode -> cmd_ctrl_node
- !DEBUG lbs_dbg_hex typo
- fix !DEBUG lbs_pr_debug
- hostcmd.h sillycaps conversion (1st pass)
- remove unused structure definitions from hostcmd.h
- hostcmd.h sillycaps conversion (2nd pass)
- fix OID_802 definitions
- convert host.h to normalcaps (1st pass)
- convert scan.c to normalcaps
- convert cmd.c to normalcaps
- convert cmdresp.c to normalcaps
- convert debugfs.c to normalcaps
- convert fw.c to normalcaps
- convert if_bootcmd.c to normalcaps
- convert if_usb.c, if_bootcmd and ioctl.c to normalcaps
- convert join.c to normalcaps
- convert wext.c to normalcaps
- convert main.c to normalcaps
- convert small headers to normalcaps
- convert types.h to normalcaps
- convert host.h to normalcaps (2nd pass)
- convert function names to normalcaps
- move processing of CMD_TYPE_{REQUEST,DATA} to inline functions
- don't do explicit casts of void* pointers
- convert remaining names to normalcaps
- wrap the subcmd data in a macro
- unify empty cases in libertas_process_rx_command
- move switch() from libertas_process_rx_command() to inline fn
- use arrays for debugfs file operations
- use get_zeroed_page/free_page on file methods (debugfs interface)

Changes since v1:

- reset usb device if boot2 init command fails
- resend initial boot command in case of non-response
- inform which command is being resent due to timeout
- do not evaluate boot command response if boot2 < v3106
- allocate bulk_out_buffer with GFP_KERNEL instead of GFP_DMA
- add event capability reporting
- remove "@file" and "@brief" headers from beginning of files
- remove now obsolete comments about driver building from README
- remove unused Makefile.old
- remove -DUPDATE_BOOT2_BY_MFG from Makefile
- fix typo and add "8388" to Kconfig entry
- remove unecessary commentary from if_bootcmd.c
- remove unecessary static attr of "struct HostCmd_DS_MESH_ACCESS" instances
- remove SLEEP_PERIOD command support code (not implemented in fw)
- hexdump should use KERN_DEBUG
- disable debugging output by default
- add might_sleep() to wait command response path
- Don't sleep inside get_wireless_stats
- version bump correction (320p0 instead of 321p0)
- destroy association worker in wlan_add_card EH path
- proper pending command accounting
- move radiotap definitions to include/net/ieee80211_radiotap.h
- added support for MPP activation/deactivation through sysfs
- remove pointer to dev structure on libertas_devs in card removal



