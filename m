From: "Graham, David" <david.graham@intel.com>
Subject: RE: [E1000-devel] [Bugme-new] [Bug 12570] New: Bonding does not
	work over e1000e.
Date: Mon, 2 Feb 2009 17:42:24 -0800
Message-ID: <13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com>
References: <8DD2590731AB5D4C9DBF71A877482A900DCA8695@orsmsx509.amr.corp.intel.com>
 <EA929A9653AAE14F841771FB1DE5A1365F60321240@rrsmsx501.amr.corp.intel.com>
 <F169D4F5E1F1974DBFAFABF47F60C10A1C2C9480@orsmsx507.amr.corp.intel.com>
 <EA929A9653AAE14F841771FB1DE5A1365F60321411@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_"
Cc: "khorenko@parallels.com" <khorenko@parallels.com>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"devel@lists.sourceforge.net" <devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39297 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbZBCBm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 20:42:27 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Konstantin.=20

I have been trying but so far been failed to reproduce the reported problem=
.=20
I have a few questions.

1) While I can't repro your problem, I can see something very similar if I =
don't load with module load parameter miimon=3D100. From your /proc/net/bon=
ding/bond1 dumps it looks like you do the right thing, but would you please=
 confirm for me by listing exactly which bonding module params you load wit=
h.=20

2) At 11:56:01 in the report you "turn on eth2 uplink on the virtual connec=
t bay5", and I see in /proc/net/bonding/bond1 , immediately after that, eth=
2 still shows MII status *down*, which would be incorrect. Can you confirm =
that this snippet of the file really is in the correct place in the reporte=
d sequence - that is, there is already a problem at this step, and that's w=
here we should look for the problem.=20

3) Could you send me your network scripts for the two slaves and the bondin=
g interface itself (on RH systems, I think that's /etc/sysconfig/networking=
-scripts/ifcfg-*. They should be modeled on the sample info in <kernel>Docu=
mentation/networking/bonding.txt, and I'd like to check them.

4) I'm probably not controlling the slave link state in the same way that y=
ou are, because in the NEC bladeserver that I'm using, I am bringing the e1=
000e link-partern ports up & down by using an admins console, using SW I do=
n't understand. I (so far) have not been able to physically disconnect one =
of the (serdes) links connecting the 82571 without also disconnecting the o=
ther, as I have to pull an entire switch module to make the disconnect. Can=
 you give me mmore information on what your system is, and how you can phys=
ically disconnect  on link at a time. Then I might be able to get hold of a=
 similar setup and see the problem.

5) I have been testing on 2.6.29-rc3 and on 2.6.28 kernels, not 2.6.29-rc1 =
which is what you reported the problem on. I think its unlikely that the pr=
oblem is only on the 2.6.29-rc1 build, but would like to know if you've had=
 a chance to try any other build, and what the results were. Also please le=
t me know if you have tested with any other non-INTEL 1GB interfaces, and i=
f you have *ever* seen bonding work properly on the system you are testing.=
=20

6) While I can't repro your issue yet, I have made some changes very recent=
ly to the serdes link detect logic in the e1000e driver. They were written =
to address a separate issue, and are actually NOT in the kernel that you ha=
ve been testing. I also can't see how fixing that problem might fix your pr=
oblem. However, because the fixes do concern serdes link detection, and so =
does yours, it's probably worth a (long) shot. If you are comfortable tryin=
g them out, I have attached them to this email. They are also being queued =
for upstream, but only after some further local testing.
=20
Thanks
Dave

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@linux-foundation.org]
>Sent: Thursday, January 29, 2009 9:53 AM
>To: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; bonding-
>devel@lists.sourceforge.net
>Cc: khorenko@parallels.com; bugme-daemon@bugzilla.kernel.org
>Subject: Re: [E1000-devel] [Bugme-new] [Bug 12570] New: Bonding does not
>work over e1000e.
>
>
>(switched to email.  Please respond via emailed reply-to-all, not via the
>bugzilla web interface).
>
>On Thu, 29 Jan 2009 03:12:01 -0800 (PST) bugme-daemon@bugzilla.kernel.org
>wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D12570
>>
>>            Summary: Bonding does not work over e1000e.
>>            Product: Drivers
>>            Version: 2.5
>>      KernelVersion: 2.6.29-rc1
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: jgarzik@pobox.com
>>         ReportedBy: khorenko@parallels.com
>>
>>
>> Checked (failing) kernel: 2.6.29-rc1
>> Latest working kernel version: unknown
>> Earliest failing kernel version: not checked but probably any. RHEL5
>kernels
>> are also affected.
>>
>> Distribution: Enterprise Linux Enterprise Linux Server release 5.1
>(Carthage)
>>
>> Hardware Environment:
>> lspci:
>> 15:00.0 Ethernet controller: Intel Corporation 82571EB Quad Port Gigabit
>> Mezzanine Adapter (rev 06)
>> 15:00.1 Ethernet controller: Intel Corporation 82571EB Quad Port Gigabit
>> Mezzanine Adapter (rev 06)
>>
>> 15:00.0 0200: 8086:10da (rev 06)
>>         Subsystem: 103c:1717
>>         Flags: bus master, fast devsel, latency 0, IRQ 154
>>         Memory at fdde0000 (32-bit, non-prefetchable) [size=3D128K]
>>         Memory at fdd00000 (32-bit, non-prefetchable) [size=3D512K]
>>         I/O ports at 6000 [size=3D32]
>>         [virtual] Expansion ROM at d1300000 [disabled] [size=3D512K]
>>         Capabilities: [c8] Power Management version 2
>>         Capabilities: [d0] Message Signalled Interrupts: 64bit+
>Queue=3D0/0
>> Enable+
>>         Capabilities: [e0] Express Endpoint IRQ 0
>>         Capabilities: [100] Advanced Error Reporting
>>         Capabilities: [140] Device Serial Number 24-d1-78-ff-ff-78-1b-00
>>
>> 15:00.1 0200: 8086:10da (rev 06)
>>         Subsystem: 103c:1717
>>         Flags: bus master, fast devsel, latency 0, IRQ 162
>>         Memory at fdce0000 (32-bit, non-prefetchable) [size=3D128K]
>>         Memory at fdc00000 (32-bit, non-prefetchable) [size=3D512K]
>>         I/O ports at 6020 [size=3D32]
>>         [virtual] Expansion ROM at d1380000 [disabled] [size=3D512K]
>>         Capabilities: [c8] Power Management version 2
>>         Capabilities: [d0] Message Signalled Interrupts: 64bit+
>Queue=3D0/0
>> Enable+
>>         Capabilities: [e0] Express Endpoint IRQ 0
>>         Capabilities: [100] Advanced Error Reporting
>>         Capabilities: [140] Device Serial Number 24-d1-78-ff-ff-78-1b-00
>>
>> Problem Description: Bonding does not work over NICs supported by
>e1000e: if
>> you brake/restore physical links of bonding slaves one by one - network
>won't
>> work anymore.
>>
>> Steps to reproduce:
>> 2 NICs supported by e1000e put into bond device (Bonding Mode: fault-
>tolerance
>> (active-backup)).
>> * ping to the outside node is ok
>> * physically brake the link of active bond slave (1)
>> * bond detects the failure, makes another slave (2) active.
>> * ping works fine
>> * restore the connection of (1)
>> * ping works fine
>> * brake the link of (2)
>> * bond detects it, reports that it makes active (1), but
>> * ping _does not_ work anymore
>>
>> Logs:
>> /var/log/messages:
>> Jan 27 11:53:29 host kernel: 0000:15:00.0: eth2: Link is Down
>> Jan 27 11:53:29 host kernel: bonding: bond1: link status definitely down
>for
>> interface eth2, disabling it
>> Jan 27 11:53:29 host kernel: bonding: bond1: making interface eth3 the
>new
>> active one.
>> Jan 27 11:56:37 host kernel: 0000:15:00.0: eth2: Link is Up 1000 Mbps
>Full
>> Duplex, Flow Control: RX/TX
>> Jan 27 11:56:37 host kernel: bonding: bond1: link status definitely up
>for
>> interface eth2.
>> Jan 27 11:57:39 host kernel: 0000:15:00.1: eth3: Link is Down
>> Jan 27 11:57:39 host kernel: bonding: bond1: link status definitely down
>for
>> interface eth3, disabling it
>> Jan 27 11:57:39 host kernel: bonding: bond1: making interface eth2 the
>new
>> active one.
>>
>> What was done + dumps of /proc/net/bonding/bond1:
>> ## 11:52:42
>> ##cat /proc/net/bonding/bond1
>> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>>
>> Bonding Mode: fault-tolerance (active-backup)
>> Primary Slave: None
>> Currently Active Slave: eth2
>> MII Status: up
>> MII Polling Interval (ms): 100
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> Slave Interface: eth2
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:17:a4:77:00:1c
>>
>> Slave Interface: eth3
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:17:a4:77:00:1e
>>
>> ## 11:53:05 shutdown eth2 uplink on the virtual connect bay5
>> ##cat /proc/net/bonding/bond1
>> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>>
>> Bonding Mode: fault-tolerance (active-backup)
>> Primary Slave: None
>> Currently Active Slave: eth3
>> MII Status: up
>> MII Polling Interval (ms): 100
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> Slave Interface: eth2
>> MII Status: down
>> Link Failure Count: 1
>> Permanent HW addr: 00:17:a4:77:00:1c
>>
>> Slave Interface: eth3
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:17:a4:77:00:1e
>>
>> ## 11:56:01 turn on eth2 uplink on the virtual connect bay5
>> ##cat /proc/net/bonding/bond1
>> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>>
>> Bonding Mode: fault-tolerance (active-backup)
>> Primary Slave: None
>> Currently Active Slave: eth3
>> MII Status: up
>> MII Polling Interval (ms): 100
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> Slave Interface: eth2
>> MII Status: down
>> Link Failure Count: 1
>> Permanent HW addr: 00:17:a4:77:00:1c
>>
>> Slave Interface: eth3
>> MII Status: up
>> Link Failure Count: 0
>> Permanent HW addr: 00:17:a4:77:00:1e
>>
>> ## 11:57:22 turn off eth3 uplink on the virtual connect bay5
>> ##cat /proc/net/bonding/bond1
>> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>>
>> Bonding Mode: fault-tolerance (active-backup)
>> Primary Slave: None
>> Currently Active Slave: eth2
>> MII Status: up
>> MII Polling Interval (ms): 100
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> Slave Interface: eth2
>> MII Status: up
>> Link Failure Count: 1
>> Permanent HW addr: 00:17:a4:77:00:1c
>>
>> Slave Interface: eth3
>> MII Status: down
>> Link Failure Count: 1
>> Permanent HW addr: 00:17:a4:77:00:1e
>>
>
>
>--------------------------------------------------------------------------
>----
>This SF.net email is sponsored by:
>SourcForge Community
>SourceForge wants to tell your story.
>http://p.sf.net/sfu/sf-spreadtheword
>_______________________________________________
>E1000-devel mailing list
>E1000-devel@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/e1000-devel

--_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_
Content-Type: application/octet-stream; name="SerdesSM.patch"
Content-Description: SerdesSM.patch
Content-Disposition: attachment; filename="SerdesSM.patch"; size=6332;
	creation-date="Fri, 30 Jan 2009 11:00:22 GMT";
	modification-date="Fri, 30 Jan 2009 11:00:22 GMT"
Content-Transfer-Encoding: base64

Y29tbWl0IDY0NjIxODI4ZWUyMDcxZGQ3MDc0MDU0MTk1MGMwNGNkNDg4ZTJmZjcKQXV0aG9yOiBk
cmdyYWhhMSA8ZHJncmFoYTFAZHJncmFoYTEtdDYwcC4obm9uZSk+CkRhdGU6ICAgRnJpIEphbiAz
MCAxMDo0MTo0MCAyMDA5IC0wODAwCgogICAgQ2hhbmdlcyB0aGUgc2VyZGVzIGxpbmsgZGV0ZWN0
aW9uIGZvciA4MjU3MSAmIDgyNTcyIGFkYXB0ZXJzIHRvIGEKICAgIHN0YXRlIG1hY2hpbmUuIFRl
c3RpbmcgaGFzIHNob3duIHRoYXQgdGhpcyBib3RoIHN0YWJpaXRpc2VzIGxpbmsKICAgIHJlcG9y
dGluZykgbm8gZmFsc2UgcG9zaXRpdmVzIGV2ZW4gb24gZGlzY29ubmVjdGVkIHNlcmRlcyBsaW5r
cykKICAgIGFuZCBwcm9wZXJseSByZXN0YXJ0cyBhdXRvbmVnb3RpYXRpb24gd2hlbiBhIGxpbmsg
cGFydGVyIGlzIHJldHVybmVkCiAgICB0byBzZXJ2aWNlLgoKZGlmZiAtLWdpdCBhL2RyaXZlcnMv
bmV0L2UxMDAwZS84MjU3MS5jIGIvZHJpdmVycy9uZXQvZTEwMDBlLzgyNTcxLmMKaW5kZXggMDg5
MDE2Mi4uMmYzY2I1ZiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZTEwMDBlLzgyNTcxLmMKKysr
IGIvZHJpdmVycy9uZXQvZTEwMDBlLzgyNTcxLmMKQEAgLTYxLDYgKzYxLDcgQEAKIHN0YXRpYyBz
MzIgZTEwMDBfZ2V0X3BoeV9pZF84MjU3MShzdHJ1Y3QgZTEwMDBfaHcgKmh3KTsKIHN0YXRpYyBz
MzIgZTEwMDBfc2V0dXBfY29wcGVyX2xpbmtfODI1NzEoc3RydWN0IGUxMDAwX2h3ICpodyk7CiBz
dGF0aWMgczMyIGUxMDAwX3NldHVwX2ZpYmVyX3NlcmRlc19saW5rXzgyNTcxKHN0cnVjdCBlMTAw
MF9odyAqaHcpOworc3RhdGljIHMzMiBlMTAwMF9jaGVja19mb3Jfc2VyZGVzX2xpbmtfODI1NzEo
c3RydWN0IGUxMDAwX2h3ICpodyk7CiBzdGF0aWMgczMyIGUxMDAwX3dyaXRlX252bV9lZXdyXzgy
NTcxKHN0cnVjdCBlMTAwMF9odyAqaHcsIHUxNiBvZmZzZXQsCiAJCQkJICAgICAgdTE2IHdvcmRz
LCB1MTYgKmRhdGEpOwogc3RhdGljIHMzMiBlMTAwMF9maXhfbnZtX2NoZWNrc3VtXzgyNTcxKHN0
cnVjdCBlMTAwMF9odyAqaHcpOwpAQCAtMjUwLDcgKzI1MSw3IEBAIHN0YXRpYyBzMzIgZTEwMDBf
aW5pdF9tYWNfcGFyYW1zXzgyNTcxKHN0cnVjdCBlMTAwMF9hZGFwdGVyICphZGFwdGVyKQogCWNh
c2UgZTEwMDBfbWVkaWFfdHlwZV9pbnRlcm5hbF9zZXJkZXM6CiAJCWZ1bmMtPnNldHVwX3BoeXNp
Y2FsX2ludGVyZmFjZSA9CiAJCQllMTAwMF9zZXR1cF9maWJlcl9zZXJkZXNfbGlua184MjU3MTsK
LQkJZnVuYy0+Y2hlY2tfZm9yX2xpbmsgPSBlMTAwMGVfY2hlY2tfZm9yX3NlcmRlc19saW5rOwor
CQlmdW5jLT5jaGVja19mb3JfbGluayA9IGUxMDAwX2NoZWNrX2Zvcl9zZXJkZXNfbGlua184MjU3
MTsKIAkJZnVuYy0+Z2V0X2xpbmtfdXBfaW5mbyA9CiAJCQllMTAwMGVfZ2V0X3NwZWVkX2FuZF9k
dXBsZXhfZmliZXJfc2VyZGVzOwogCQlicmVhazsKQEAgLTgzMCw2ICs4MzEsMTAgQEAgc3RhdGlj
IHMzMiBlMTAwMF9yZXNldF9od184MjU3MShzdHJ1Y3QgZTEwMDBfaHcgKmh3KQogCQlody0+ZGV2
X3NwZWMuZTgyNTcxLmFsdF9tYWNfYWRkcl9pc19wcmVzZW50KQogCQkJZTEwMDBlX3NldF9sYWFf
c3RhdGVfODI1NzEoaHcsIHRydWUpOwogCisJLyogUmVpbml0aWFsaXplIHRoZSA4MjU3MSBzZXJk
ZXMgbGluayBzdGF0ZSBtYWNoaW5lICovCisJaWYgKGh3LT5waHkubWVkaWFfdHlwZSA9PSBlMTAw
MF9tZWRpYV90eXBlX2ludGVybmFsX3NlcmRlcykKKwkJaHctPm1hYy5zZXJkZXNfbGlua19zdGF0
ZSA9IGUxMDAwX3NlcmRlc19saW5rX2Rvd247CisKIAlyZXR1cm4gMDsKIH0KIApAQCAtMTIwMyw2
ICsxMjA4LDEzMSBAQCBzdGF0aWMgczMyIGUxMDAwX3NldHVwX2ZpYmVyX3NlcmRlc19saW5rXzgy
NTcxKHN0cnVjdCBlMTAwMF9odyAqaHcpCiB9CiAKIC8qKgorICogIGUxMDAwX2NoZWNrX2Zvcl9z
ZXJkZXNfbGlua184MjU3MSAtIENoZWNrIGZvciBsaW5rIChTZXJkZXMpCisgKiAgQGh3OiBwb2lu
dGVyIHRvIHRoZSBIVyBzdHJ1Y3R1cmUKKyAqCisgKiAgQ2hlY2tzIGZvciBsaW5rIHVwIG9uIHRo
ZSBoYXJkd2FyZS4gIElmIGxpbmsgaXMgbm90IHVwIGFuZCB3ZSBoYXZlCisgKiAgYSBzaWduYWws
IHRoZW4gd2UgbmVlZCB0byBmb3JjZSBsaW5rIHVwLgorICoqLworczMyIGUxMDAwX2NoZWNrX2Zv
cl9zZXJkZXNfbGlua184MjU3MShzdHJ1Y3QgZTEwMDBfaHcgKmh3KQoreworCXN0cnVjdCBlMTAw
MF9tYWNfaW5mbyAqbWFjID0gJmh3LT5tYWM7CisJdTMyIHJ4Y3c7CisJdTMyIGN0cmw7CisJdTMy
IHN0YXR1czsKKwlzMzIgcmV0X3ZhbCA9IDA7CisKKwljdHJsID0gZXIzMihDVFJMKTsKKwlzdGF0
dXMgPSBlcjMyKFNUQVRVUyk7CisJcnhjdyA9IGVyMzIoUlhDVyk7CisKKwlpZiAoKHJ4Y3cgJiBF
MTAwMF9SWENXX1NZTkNIKSAmJiAhKHJ4Y3cgJiBFMTAwMF9SWENXX0lWKSkgeworCisJCS8qIFJl
Y2VpdmVyIGlzIHN5bmNocm9uaXplZCB3aXRoIG5vIGludmFsaWQgYml0cy4gICovCisJCXN3aXRj
aCAobWFjLT5zZXJkZXNfbGlua19zdGF0ZSkgeworCQljYXNlIGUxMDAwX3NlcmRlc19saW5rX2F1
dG9uZWdfY29tcGxldGU6CisJCQlpZiAoIShzdGF0dXMgJiBFMTAwMF9TVEFUVVNfTFUpKSB7CisJ
CQkJLyoKKwkJCQkgKiBXZSBoYXZlIGxvc3QgbGluaywgcmV0cnkgYXV0b25lZyBiZWZvcmUKKwkJ
CQkgKiByZXBvcnRpbmcgbGluayBmYWlsdXJlCisJCQkJICovCisJCQkJbWFjLT5zZXJkZXNfbGlu
a19zdGF0ZSA9CisJCQkJICAgIGUxMDAwX3NlcmRlc19saW5rX2F1dG9uZWdfcHJvZ3Jlc3M7CisJ
CQkJaHdfZGJnKGh3LCAiQU5fVVAgICAgIC0+IEFOX1BST0dcbiIpOworCQkJfQorCQlicmVhazsK
KworCQljYXNlIGUxMDAwX3NlcmRlc19saW5rX2ZvcmNlZF91cDoKKwkJCS8qCisJCQkgKiBJZiB3
ZSBhcmUgcmVjZWl2aW5nIC9DLyBvcmRlcmVkIHNldHMsIHJlLWVuYWJsZQorCQkJICogYXV0by1u
ZWdvdGlhdGlvbiBpbiB0aGUgVFhDVyByZWdpc3RlciBhbmQgZGlzYWJsZQorCQkJICogZm9yY2Vk
IGxpbmsgaW4gdGhlIERldmljZSBDb250cm9sIHJlZ2lzdGVyIGluIGFuCisJCQkgKiBhdHRlbXB0
IHRvIGF1dG8tbmVnb3RpYXRlIHdpdGggb3VyIGxpbmsgcGFydG5lci4KKwkJCSAqLworCQkJaWYg
KHJ4Y3cgJiBFMTAwMF9SWENXX0MpIHsKKwkJCQkvKiBFbmFibGUgYXV0b25lZywgYW5kIHVuZm9y
Y2UgbGluayB1cCAqLworCQkJCWV3MzIoVFhDVywgbWFjLT50eGN3KTsKKwkJCQlldzMyKENUUkws
CisJCQkJICAgIChjdHJsICYgfkUxMDAwX0NUUkxfU0xVKSk7CisJCQkJbWFjLT5zZXJkZXNfbGlu
a19zdGF0ZSA9CisJCQkJICAgIGUxMDAwX3NlcmRlc19saW5rX2F1dG9uZWdfcHJvZ3Jlc3M7CisJ
CQkJaHdfZGJnKGh3LCAiRk9SQ0VEX1VQIC0+IEFOX1BST0dcbiIpOworCQkJfQorCQkJYnJlYWs7
CisKKwkJY2FzZSBlMTAwMF9zZXJkZXNfbGlua19hdXRvbmVnX3Byb2dyZXNzOgorCQkJLyoKKwkJ
CSAqIElmIHRoZSBMVSBiaXQgaXMgc2V0IGluIHRoZSBTVEFUVVMgcmVnaXN0ZXIsCisJCQkgKiBh
dXRvbmVnIGhhcyBjb21wbGV0ZWQgc3VjZXNzZnVsbHkuIElmIG5vdCwKKwkJCSAqIHRyeSBmb3Jp
bmcgdGhlIGxpbmsgYmVjYXVzZSB0aGUgZmFyIGVuZCBtYXkgYmUKKwkJCSAqIGF2YWlsYWJsZSBi
dXQgbm90IGNhcGFibGUgb2YgYXV0b25lZ290aWF0aW9uLgorCQkJICovCisJCQlpZiAoc3RhdHVz
ICYgRTEwMDBfU1RBVFVTX0xVKSAgeworCQkJCW1hYy0+c2VyZGVzX2xpbmtfc3RhdGUgPQorCQkJ
CSAgICBlMTAwMF9zZXJkZXNfbGlua19hdXRvbmVnX2NvbXBsZXRlOworCQkJCWh3X2RiZyhodywg
IkFOX1BST0cgICAtPiBBTl9VUFxuIik7CisJCQl9IGVsc2UgeworCQkJCS8qCisJCQkJICogRGlz
YWJsZSBhdXRvbmVnLCBmb3JjZSBsaW5rIHVwIGFuZAorCQkJCSAqIGZ1bGwgZHVwbGV4LCBhbmQg
Y2hhbmdlIHN0YXRlIHRvIGZvcmNlZAorCQkJCSAqLworCQkJCWV3MzIoVFhDVywKKwkJCQkgICAg
KG1hYy0+dHhjdyAmIH5FMTAwMF9UWENXX0FORSkpOworCQkJCWN0cmwgfD0gKEUxMDAwX0NUUkxf
U0xVIHwgRTEwMDBfQ1RSTF9GRCk7CisJCQkJZXczMihDVFJMLCBjdHJsKTsKKworCQkJCS8qIENv
bmZpZ3VyZSBGbG93IENvbnRyb2wgYWZ0ZXIgbGluayB1cC4gKi8KKwkJCQlyZXRfdmFsID0KKwkJ
CQkgICAgZTEwMDBlX2NvbmZpZ19mY19hZnRlcl9saW5rX3VwKGh3KTsKKwkJCQlpZiAocmV0X3Zh
bCkgeworCQkJCQlod19kYmcoaHcsICJFcnJvciBjb25maWcgZmxvdyBjb250cm9sXG4iKTsKKwkJ
CQkJYnJlYWs7CisJCQkJfQorCQkJCW1hYy0+c2VyZGVzX2xpbmtfc3RhdGUgPQorCQkJCSAgICBl
MTAwMF9zZXJkZXNfbGlua19mb3JjZWRfdXA7CisJCQkJaHdfZGJnKGh3LCAiQU5fUFJPRyAgIC0+
IEZPUkNFRF9VUFxuIik7CisJCQl9CisJCQltYWMtPnNlcmRlc19oYXNfbGluayA9IHRydWU7CisJ
CQlicmVhazsKKworCQljYXNlIGUxMDAwX3NlcmRlc19saW5rX2Rvd246CisJCWRlZmF1bHQ6CisJ
CQkvKiBUaGUgbGluayB3YXMgZG93biBidXQgdGhlIHJlY2VpdmVyIGhhcyBub3cgZ2FpbmVkCisJ
CQkgKiB2YWxpZCBzeW5jLCBzbyBsZXRzIHNlZSBpZiB3ZSBjYW4gYnJpbmcgdGhlIGxpbmsKKwkJ
CSAqIHVwLiAqLworCQkJZXczMihUWENXLCBtYWMtPnR4Y3cpOworCQkJZXczMihDVFJMLAorCQkJ
ICAgIChjdHJsICYgfkUxMDAwX0NUUkxfU0xVKSk7CisJCQltYWMtPnNlcmRlc19saW5rX3N0YXRl
ID0KKwkJCSAgICBlMTAwMF9zZXJkZXNfbGlua19hdXRvbmVnX3Byb2dyZXNzOworCQkJaHdfZGJn
KGh3LCAiRE9XTiAgICAgIC0+IEFOX1BST0dcbiIpOworCQkJYnJlYWs7CisJCX0KKwl9IGVsc2Ug
eworCQlpZiAoIShyeGN3ICYgRTEwMDBfUlhDV19TWU5DSCkpIHsKKwkJCW1hYy0+c2VyZGVzX2hh
c19saW5rID0gZmFsc2U7CisJCQltYWMtPnNlcmRlc19saW5rX3N0YXRlID0gZTEwMDBfc2VyZGVz
X2xpbmtfZG93bjsKKwkJCWh3X2RiZyhodywgIkFOWVNUQVRFICAtPiBET1dOXG4iKTsKKwkJfSBl
bHNlIHsKKwkJCS8qCisJCQkgKiBXZSBoYXZlIHN5bmMsIGFuZCBjYW4gdG9sZXJhdGUgb25lCisJ
CQkgKiBpbnZhbGlkIChJVikgY29kZXdvcmQgYmVmb3JlIGRlY2xhcmluZworCQkJICogbGluayBk
b3duLCBzbyByZXJlYWQgdG8gbG9vayBhZ2FpbgorCQkJICovCisJCQl1ZGVsYXkoMTApOworCQkJ
cnhjdyA9IGVyMzIoUlhDVyk7CisJCQlpZiAocnhjdyAmIEUxMDAwX1JYQ1dfSVYpIHsKKwkJCQlt
YWMtPnNlcmRlc19saW5rX3N0YXRlID0gZTEwMDBfc2VyZGVzX2xpbmtfZG93bjsKKwkJCQltYWMt
PnNlcmRlc19oYXNfbGluayA9IGZhbHNlOworCQkJCWh3X2RiZyhodywgIkFOWVNUQVRFICAtPiBE
T1dOXG4iKTsKKwkJCX0KKwkJfQorCX0KKworCXJldHVybiByZXRfdmFsOworfQorCisvKioKICAq
ICBlMTAwMF92YWxpZF9sZWRfZGVmYXVsdF84MjU3MSAtIFZlcmlmeSBhIHZhbGlkIGRlZmF1bHQg
TEVEIGNvbmZpZwogICogIEBodzogcG9pbnRlciB0byB0aGUgSFcgc3RydWN0dXJlCiAgKiAgQGRh
dGE6IHBvaW50ZXIgdG8gdGhlIE5WTSAoRUVQUk9NKQpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQv
ZTEwMDBlL2h3LmggYi9kcml2ZXJzL25ldC9lMTAwMGUvaHcuaAppbmRleCAyZDRjZTA0Li5kZTJi
ZTFmIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9lMTAwMGUvaHcuaAorKysgYi9kcml2ZXJzL25l
dC9lMTAwMGUvaHcuaApAQCAtNDU5LDYgKzQ1OSwxMyBAQCBlbnVtIGUxMDAwX3NtYXJ0X3NwZWVk
IHsKIAllMTAwMF9zbWFydF9zcGVlZF9vZmYKIH07CiAKK2VudW0gZTEwMDBfc2VyZGVzX2xpbmtf
c3RhdGUgeworCWUxMDAwX3NlcmRlc19saW5rX2Rvd24gPSAwLAorCWUxMDAwX3NlcmRlc19saW5r
X2F1dG9uZWdfcHJvZ3Jlc3MsCisJZTEwMDBfc2VyZGVzX2xpbmtfYXV0b25lZ19jb21wbGV0ZSwK
KwllMTAwMF9zZXJkZXNfbGlua19mb3JjZWRfdXAKK307CisKIC8qIFJlY2VpdmUgRGVzY3JpcHRv
ciAqLwogc3RydWN0IGUxMDAwX3J4X2Rlc2MgewogCV9fbGU2NCBidWZmZXJfYWRkcjsgLyogQWRk
cmVzcyBvZiB0aGUgZGVzY3JpcHRvcidzIGRhdGEgYnVmZmVyICovCkBAIC03ODYsNyArNzkzLDgg
QEAgc3RydWN0IGUxMDAwX21hY19pbmZvIHsKIAlib29sIGdldF9saW5rX3N0YXR1czsKIAlib29s
IGluX2lmc19tb2RlOwogCWJvb2wgc2VyZGVzX2hhc19saW5rOwotCWJvb2wgdHhfcGt0X2ZpbHRl
cmluZzsKKwllbnVtIGUxMDAwX3NlcmRlc19saW5rX3N0YXRlIHNlcmRlc19saW5rX3N0YXRlOwor
ICAgICAgIAlib29sIHR4X3BrdF9maWx0ZXJpbmc7CiB9OwogCiBzdHJ1Y3QgZTEwMDBfcGh5X2lu
Zm8gewo=

--_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_
Content-Type: application/octet-stream; name="disable_dmaclkgating.patch"
Content-Description: disable_dmaclkgating.patch
Content-Disposition: attachment; filename="disable_dmaclkgating.patch";
	size=1776; creation-date="Fri, 30 Jan 2009 11:01:34 GMT";
	modification-date="Fri, 30 Jan 2009 11:01:34 GMT"
Content-Transfer-Encoding: base64

Y29tbWl0IGYxODliMDJjZTViZjcyMzNlOWFhMjE3YjU2MWQwYjRlYzBhODE4YjMKQXV0aG9yOiBk
cmdyYWhhMSA8ZHJncmFoYTFAZHJncmFoYTEtdDYwcC4obm9uZSk+CkRhdGU6ICAgRnJpIEphbiAz
MCAxMDo1NToyMyAyMDA5IC0wODAwCgogICAgU29tZSA4MjU3MSBhZGFwdGVycyB3ZXJlIHNoaXBw
ZWQgd2l0aCB0ZWggZWVwcm9tIHNldHRpbmcgb2YKICAgIERNQSBkeW5hbWljIGNsb2NrIGdhdGlu
ZyBlbmFibGVkLiBJdCBoc291bGQgYmUgZGlzYWJsZWQsIGFuZAogICAgdGhpcyBwYXRjaCBmb3Jj
ZS1kaXNhYmxlcyB0aGUgc2V0dGluZyBpbiB0aGUgQ1RSTF9FWFQKICAgIHJlZ2lzdGVyIChpbml0
aWFsbHkgbWFwcGVkIGZvcm0gdGhlIEVFUFJPTSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9l
MTAwMGUvODI1NzEuYyBiL2RyaXZlcnMvbmV0L2UxMDAwZS84MjU3MS5jCmluZGV4IDJmM2NiNWYu
LjU2NWZkNGUgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2UxMDAwZS84MjU3MS5jCisrKyBiL2Ry
aXZlcnMvbmV0L2UxMDAwZS84MjU3MS5jCkBAIC05ODUsNiArOTg1LDE4IEBAIHN0YXRpYyB2b2lk
IGUxMDAwX2luaXRpYWxpemVfaHdfYml0c184MjU3MShzdHJ1Y3QgZTEwMDBfaHcgKmh3KQogCQly
ZWcgfD0gRTEwMDBfUEJBX0VDQ19DT1JSX0VOOwogCQlldzMyKFBCQV9FQ0MsIHJlZyk7CiAJfQor
CS8qCisJICogV29ya2Fyb3VuZCBmb3IgaGFyZHdhcmUgZXJyYXRhLgorCSAqIEVuc3VyZSB0aGF0
IERNQSBEeW5hbWljIENsb2NrIGdhdGluZyBpcyBkaXNhYmxlZCBvbiA4MjU3MSBhbmQgODI1NzIK
KwkgKi8KKworICAgICAgICBpZiAoKGh3LT5tYWMudHlwZSA9PSBlMTAwMF84MjU3MSkgfHwKKyAg
ICAgICAgICAgKGh3LT5tYWMudHlwZSA9PSBlMTAwMF84MjU3MikpIHsKKyAgICAgICAgICAgICAg
ICByZWcgPSBlcjMyKENUUkxfRVhUKTsKKyAgICAgICAgICAgICAgICByZWcgJj0gfkUxMDAwX0NU
UkxfRVhUX0RNQV9EWU5fQ0xLX0VOOworICAgICAgICAgICAgICAgIGV3MzIoQ1RSTF9FWFQsIHJl
Zyk7CisgICAgICAgIH0KKwogCiAJLyogUENJLUV4IENvbnRyb2wgUmVnaXN0ZXJzICovCiAJaWYg
KGh3LT5tYWMudHlwZSA9PSBlMTAwMF84MjU3NCkgewpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQv
ZTEwMDBlL2RlZmluZXMuaCBiL2RyaXZlcnMvbmV0L2UxMDAwZS9kZWZpbmVzLmgKaW5kZXggZTZj
YWYyOS4uMjQzYWE0OSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZTEwMDBlL2RlZmluZXMuaAor
KysgYi9kcml2ZXJzL25ldC9lMTAwMGUvZGVmaW5lcy5oCkBAIC02OSw2ICs2OSw3IEBACiAjZGVm
aW5lIEUxMDAwX0NUUkxfRVhUX1NEUDdfREFUQSAweDAwMDAwMDgwIC8qIFZhbHVlIG9mIFNXIERl
ZmluYWJsZSBQaW4gNyAqLwogI2RlZmluZSBFMTAwMF9DVFJMX0VYVF9FRV9SU1QgICAgMHgwMDAw
MjAwMCAvKiBSZWluaXRpYWxpemUgZnJvbSBFRVBST00gKi8KICNkZWZpbmUgRTEwMDBfQ1RSTF9F
WFRfUk9fRElTICAgIDB4MDAwMjAwMDAgLyogUmVsYXhlZCBPcmRlcmluZyBkaXNhYmxlICovCisj
ZGVmaW5lIEUxMDAwX0NUUkxfRVhUX0RNQV9EWU5fQ0xLX0VOIDB4MDAwODAwMDAgLyogRE1BIER5
bmFtaWMgQ2xvY2sgR2F0aW5nICovCiAjZGVmaW5lIEUxMDAwX0NUUkxfRVhUX0xJTktfTU9ERV9N
QVNLIDB4MDBDMDAwMDAKICNkZWZpbmUgRTEwMDBfQ1RSTF9FWFRfTElOS19NT0RFX1BDSUVfU0VS
REVTICAweDAwQzAwMDAwCiAjZGVmaW5lIEUxMDAwX0NUUkxfRVhUX0VJQU1FICAgICAgICAgIDB4
MDEwMDAwMDAK

--_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_
Content-Type: application/octet-stream; name="RemoveRXSEQ.patch"
Content-Description: RemoveRXSEQ.patch
Content-Disposition: attachment; filename="RemoveRXSEQ.patch"; size=1223;
	creation-date="Fri, 30 Jan 2009 11:01:02 GMT";
	modification-date="Fri, 30 Jan 2009 11:01:02 GMT"
Content-Transfer-Encoding: base64

Y29tbWl0IGY4NjU4OTU1YWUyODQxNWYxZDgzZWQ0YzcyZWQ0NjMyYTczNjhlMjYKQXV0aG9yOiBk
cmdyYWhhMSA8ZHJncmFoYTFAZHJncmFoYTEtdDYwcC4obm9uZSk+CkRhdGU6ICAgRnJpIEphbiAz
MCAxMDo0ODoxNyAyMDA5IC0wODAwCgogICAgUmVtb3ZlIHRoZSBMU0MtbGlrZSB0cmVhdG1lbnQg
dGhhdCBpcyBnaXZlbiB0byBSWFNFUSBpbnRlcnJ1dHBzLgogICAgSXQgaXMgdGhvdWdodCB0aGF0
IHRoaXMgd2FzIGluaXRpYWxseSBhZGRlZCB0byBhc3Npc3QgaW4gc2VyZGVzCiAgICBsaW5rIGRl
dGVjdGlvbiB3aGljaCB3b3VsZCBub3QgYWx3YXlzIGluZGljYXRlIGEgbGluay1kb3duIGludGVy
cnVwdAogICAgd2hlbiBhIGxpbmsgcGFydGVucmUgd2FzIHJlbW92ZWQgZnJvbSBzZXJ2aWNlLiBU
aGUgbmV3IGxpbmsgZGV0ZWN0CiAgICBtZWNoYW5pc20gZm9yIHNlcmRlcyBubyBsb25nZXIgcmVx
dWlyZXMgdGhpcy4KCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9lMTAwMGUvbmV0ZGV2LmMgYi9k
cml2ZXJzL25ldC9lMTAwMGUvbmV0ZGV2LmMKaW5kZXggOTE4MTdkMC4uNTViMmY2YiAxMDA2NDQK
LS0tIGEvZHJpdmVycy9uZXQvZTEwMDBlL25ldGRldi5jCisrKyBiL2RyaXZlcnMvbmV0L2UxMDAw
ZS9uZXRkZXYuYwpAQCAtMTE1Miw3ICsxMTUyLDcgQEAgc3RhdGljIGlycXJldHVybl90IGUxMDAw
X2ludHJfbXNpKGludCBpcnEsIHZvaWQgKmRhdGEpCiAJICogcmVhZCBJQ1IgZGlzYWJsZXMgaW50
ZXJydXB0cyB1c2luZyBJQU0KIAkgKi8KIAotCWlmIChpY3IgJiAoRTEwMDBfSUNSX1JYU0VRIHwg
RTEwMDBfSUNSX0xTQykpIHsKKwlpZiAoaWNyICYgRTEwMDBfSUNSX0xTQykgewogCQlody0+bWFj
LmdldF9saW5rX3N0YXR1cyA9IDE7CiAJCS8qCiAJCSAqIElDSDggd29ya2Fyb3VuZC0tIENhbGwg
Z2lnIHNwZWVkIGRyb3Agd29ya2Fyb3VuZCBvbiBjYWJsZQpAQCAtMTIxOCw3ICsxMjE4LDcgQEAg
c3RhdGljIGlycXJldHVybl90IGUxMDAwX2ludHIoaW50IGlycSwgdm9pZCAqZGF0YSkKIAkgKiBJ
TUMgd3JpdGUKIAkgKi8KIAotCWlmIChpY3IgJiAoRTEwMDBfSUNSX1JYU0VRIHwgRTEwMDBfSUNS
X0xTQykpIHsKKwlpZiAoaWNyICYgRTEwMDBfSUNSX0xTQykgewogCQlody0+bWFjLmdldF9saW5r
X3N0YXR1cyA9IDE7CiAJCS8qCiAJCSAqIElDSDggd29ya2Fyb3VuZC0tIENhbGwgZ2lnIHNwZWVk
IGRyb3Agd29ya2Fyb3VuZCBvbiBjYWJsZQo=

--_004_13830B75AD5A2F42848F92269B11996F3A0F5952orsmsx509amrcor_--
