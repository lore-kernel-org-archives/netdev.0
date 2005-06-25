From: randy_dunlap <rdunlap@xenotime.net>
Subject: Re: tg3: issue for reboot/kexec
Date: Fri, 24 Jun 2005 17:46:52 -0700
Message-ID: <20050624174652.159f26ce.rdunlap@xenotime.net>
References: <42BC9F09.1060002@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0047875890068609372=="
Cc: netdev@vger.kernel.org, fastboot@lists.osdl.org, linux-pm@lists.osdl.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Haren Myneni <haren@us.ibm.com>
In-Reply-To: <42BC9F09.1060002@us.ibm.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============0047875890068609372==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 24 Jun 2005 17:02:17 -0700 Haren Myneni wrote:

| 
| Hello,
|     The kexec boot on power blade (JS20) is not successfull without 
| doing 'ifdown <ethernet device>'.  Based on my initial look in tg3 code, 
| the driver does not have shutdown nor reboot notifier code unlike in 
| other drivers. Hence, I added the the following patch (based on e1000) 
| and it is working. Is it OK to include this patch? If not, any help to 
| track down the issue would be appreciated.
| 
| My system is having the following cards:
| 0000:11:01.0 Ethernet controller: Broadcom Corporation NetXtreme 
| BCM5704S Gigabit Ethernet (rev 03)
| 0000:11:01.1 Ethernet controller: Broadcom Corporation NetXtreme 
| BCM5704S Gigabit Ethernet (rev 03)
| 
| lspci -n -s 0000:11:01
| 0000:11:01.0 Class 0200: 14e4:16a8 (rev 03)
| 0000:11:01.1 Class 0200: 14e4:16a8 (rev 03)

[adding fastboot & linux-pm mailing lists]

There was just a SCSI driver patch that tried to use a reboot
notifier on shutdown and the patch got this comment:

Subject: Re: [PATCH] 2.6 aacraid: shutdown notification
Message-ID: <42BC6D6F.5090402@us.ibm.com>
From:	Mark Haverkamp <markh@osdl.org>

and reply From:	Brian King <brking@us.ibm.com>:
| The pci_driver->shutdown method should be used instead of registering
| a reboot notifier.

so is there a good reason that network drivers should use the
reboot notifier instead of pci_driver->shutdown,
or should we be converting drivers to use pci_driver->shutdown
instead?
My quick look favors pci_driver->shutdown.

---
~Randy

--===============0047875890068609372==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============0047875890068609372==--
