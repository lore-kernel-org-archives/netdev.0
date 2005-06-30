From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 30 Jun 2005 17:52:55 -0600
Message-ID: <m1vf3vjtbc.fsf@ebiederm.dsl.xmission.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
	<20050630233354.GA22287@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============45828000169482541=="
Cc: netdev@vger.kernel.org, fastboot@lists.osdl.org, linux-pm@lists.osdl.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20050630233354.GA22287@kroah.com> (Greg KH's message of "Thu,
	30 Jun 2005 16:33:55 -0700")
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

--===============45828000169482541==
Content-Type: text/plain; charset=us-ascii

Greg KH <greg@kroah.com> writes:

> On Thu, Jun 30, 2005 at 05:21:45PM -0600, Eric W. Biederman wrote:
>> However I have gotten feedback a couple of times that
>> driver writers tend to prefer using reboot notifiers.  In part
>> because shutdown functions don't exist for non-pci devices.
>
> That's a very lame excuse.  All busses should have shutdown functions.
> And any device that is just bypassing all of the existing bus logic is
> still tying into the driver core directly (which is a bad thing by
> itself, but that's a different matter.)  And there's a shutdown method
> there too.
>
> So there is no excuse to not use it.  Please, if they complain, point
> them to me :)

Ok.

Then there is still my complaint and device_shutdown doesn't get called
on module removal which means it really doesn't get implemented.  Perhaps
with kexec now being in the mainline kernel this will get better.

Currently I have the following patch outstanding against the e1000
driver because on reboot on some boxes it card revisions
it places the card into a sleep state the driver initialization 
routing cannot get the card out of.

And yes the e1000 is bad and is using a reboot_notifier.

Eric

 e1000_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -uNr linux-2.4.29-kexec-apic-virtwire-on-shutdownx86_64/drivers/net/e1000/e1000_main.c linux-2.4.29-e1000-no-poweroff-on-reboot/drivers/net/e1000/e1000_main.c
--- linux-2.4.29-kexec-apic-virtwire-on-shutdownx86_64/drivers/net/e1000/e1000_main.c   Tue Feb 15 14:17:09 2005
+++ linux-2.4.29-e1000-no-poweroff-on-reboot/drivers/net/e1000/e1000_main.c     Wed Feb 16 05:49:00 2005
@@ -2777,7 +2777,7 @@
        case SYS_POWER_OFF:
                while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
                        if(pci_dev_driver(pdev) == &e1000_driver)
-                               e1000_suspend(pdev, 3);
+                               e1000_suspend(pdev, (event == SYS_DOWN)?0:3);
                }
        }
       return NOTIFY_DONE;

--===============45828000169482541==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============45828000169482541==--
