From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 30 Jun 2005 17:21:45 -0600
Message-ID: <m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============24627532072974345=="
Cc: netdev@vger.kernel.org, fastboot@lists.osdl.org, linux-pm@lists.osdl.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20050625033328.GC3934@kroah.com> (Greg KH's message of "Fri,
	24 Jun 2005 20:33:28 -0700")
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============24627532072974345==
Content-Type: text/plain; charset=us-ascii

Greg KH <greg@kroah.com> writes:

> On Fri, Jun 24, 2005 at 05:46:52PM -0700, randy_dunlap wrote:
>> On Fri, 24 Jun 2005 17:02:17 -0700 Haren Myneni wrote:
>> 
>> | 
>> | Hello,
>> |     The kexec boot on power blade (JS20) is not successfull without 
>> | doing 'ifdown <ethernet device>'.  Based on my initial look in tg3 code, 
>> | the driver does not have shutdown nor reboot notifier code unlike in 
>> | other drivers. Hence, I added the the following patch (based on e1000) 
>> | and it is working. Is it OK to include this patch? If not, any help to 
>> | track down the issue would be appreciated.
>> | 
>> | My system is having the following cards:
>> | 0000:11:01.0 Ethernet controller: Broadcom Corporation NetXtreme 
>> | BCM5704S Gigabit Ethernet (rev 03)
>> | 0000:11:01.1 Ethernet controller: Broadcom Corporation NetXtreme 
>> | BCM5704S Gigabit Ethernet (rev 03)
>> | 
>> | lspci -n -s 0000:11:01
>> | 0000:11:01.0 Class 0200: 14e4:16a8 (rev 03)
>> | 0000:11:01.1 Class 0200: 14e4:16a8 (rev 03)
>> 
>> [adding fastboot & linux-pm mailing lists]
>> 
>> There was just a SCSI driver patch that tried to use a reboot
>> notifier on shutdown and the patch got this comment:
>> 
>> Subject: Re: [PATCH] 2.6 aacraid: shutdown notification
>> Message-ID: <42BC6D6F.5090402@us.ibm.com>
>> From:	Mark Haverkamp <markh@osdl.org>
>> 
>> and reply From:	Brian King <brking@us.ibm.com>:
>> | The pci_driver->shutdown method should be used instead of registering
>> | a reboot notifier.
>> 
>> so is there a good reason that network drivers should use the
>> reboot notifier instead of pci_driver->shutdown,
>> or should we be converting drivers to use pci_driver->shutdown
>> instead?
>> My quick look favors pci_driver->shutdown.

A couple stray bits of feedback.  Downing the interface is generally
a user space requirement like unmounting filesystems.
/sbin/kexec and /sbin/reboot both perform this operation so I don't
see how this bug was hit.

I am wondering here if the problem was on on going DMA transaction
or something else.  If the problem was not an on going DMA transaction
then this problem is going to crop back up when people start
messing with the kexec on panic, because it indicates the
driver initialization is not robust.

> Yes, don't add a reboot notifier, use the shutdown function instead.

Sounds right to me.

However I have gotten feedback a couple of times that
driver writers tend to prefer using reboot notifiers.  In part
because shutdown functions don't exist for non-pci devices.

Eric

--===============24627532072974345==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============24627532072974345==--
