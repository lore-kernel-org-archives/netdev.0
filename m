From: jacob jacob <opstkusr@gmail.com>
Subject: Re: [Qemu-devel] PCI passthrough of 40G ethernet interface (Openstack/KVM)
Date: Thu, 19 Mar 2015 17:04:18 -0400
Message-ID: <CA+AkT2gHKtz2bKSf2FB+3+XkDidBnUDQSZy_KPb1y-MG+QnSiw@mail.gmail.com>
References: <CA+AkT2g=vFxKAUrHzWDxPzfq_SNvOUJvzHe5YsX+p+p6Ad8hog@mail.gmail.com>
	<jpg8uf2ghln.fsf@redhat.com>
	<CA+AkT2hZ5e=YRkSqQnpQm9CgfC_fqs-m_05FTRZQLt9ynj9A4w@mail.gmail.com>
	<jpgtwxpvk5x.fsf@redhat.com>
	<CA+AkT2j9UUTVmEsW1B4D_cvfCTjp-+62qhvnYxcrthy=QmQcaw@mail.gmail.com>
	<CA+AkT2gXouCdMWzRJBY0jYi6O61OjDnNf7XGnfLzhYkJCe00mg@mail.gmail.com>
	<jpg1tko7qwb.fsf@redhat.com>
	<CA+AkT2i2z+DGV0aezUQaOLKrVupprniuxC19xGOuNnd6gC1ZGg@mail.gmail.com>
	<jpglhiw4tal.fsf@redhat.com>
	<jpgk2yewcpt.fsf@redhat.com>
	<CA+AkT2g-Xt+hcpoh2ETx70v0mzV6m=-5zpxJrhs2C8WF--kmWw@mail.gmail.com>
	<CAP-MU4PSMMOv-sjfDtKOSaHa9-dy3cMovsHV7V_cV1k6N7yvFg@mail.gmail.com>
	<CAP-MU4Pfv9W9FgaLxwOac3LnSJMxWcbYP4Pq43YjcJ9AWAamvQ@mail.gmail.com>
	<550A85B3.4070703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	Bandan Das <bsd@redhat.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	QEMU Developers <qemu-devel@nongnu.org>,
	kvm-devel <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35041 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbCSVET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:04:19 -0400
In-Reply-To: <550A85B3.4070703@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have updated to latest firmware and still no luck.


]# ethtool -i eth1
driver: i40e
version: 1.2.37
firmware-version: f4.33.31377 a1.2 n4.42 e1930
bus-info: 0000:00:05.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes


Seeing similar results as before :
1)Everything works fine on host (used i40e version 1.2.37 and dpdk 1.8.0)

2)In vm tried both i40e driver version 1.2.37 and dpdk 1.8.0 and data
tx  fails (I have 2 40G interfaces passed through to a VM):See the
following error now in the VM which looks interesting...

[    5.449672] i40e 0000:00:06.0: f4.33.31377 a1.2 n4.42 e1930
[    5.525061] i40e 0000:00:06.0: FCoE capability is disabled
[    5.528786] i40e 0000:00:06.0: MAC address: 68:05:ca:2e:80:50
[    5.534491] i40e 0000:00:06.0: SAN MAC: 68:05:ca:2e:80:54
[    5.544081] i40e 0000:00:06.0: AQ Querying DCB configuration failed: aq_err 1
[    5.545870] i40e 0000:00:06.0: DCB init failed -53, disabled
[    5.547462] i40e 0000:00:06.0: fcoe queues = 0
[    5.548970] i40e 0000:00:06.0: irq 43 for MSI/MSI-X
[    5.548987] i40e 0000:00:06.0: irq 44 for MSI/MSI-X
[    5.549012] i40e 0000:00:06.0: irq 45 for MSI/MSI-X
[    5.549028] i40e 0000:00:06.0: irq 46 for MSI/MSI-X
[    5.549044] i40e 0000:00:06.0: irq 47 for MSI/MSI-X
[    5.549059] i40e 0000:00:06.0: irq 48 for MSI/MSI-X
[    5.549074] i40e 0000:00:06.0: irq 49 for MSI/MSI-X
[    5.549089] i40e 0000:00:06.0: irq 50 for MSI/MSI-X
[    5.549103] i40e 0000:00:06.0: irq 51 for MSI/MSI-X
[    5.549117] i40e 0000:00:06.0: irq 52 for MSI/MSI-X
[    5.549132] i40e 0000:00:06.0: irq 53 for MSI/MSI-X
[    5.549146] i40e 0000:00:06.0: irq 54 for MSI/MSI-X
[    5.549160] i40e 0000:00:06.0: irq 55 for MSI/MSI-X
[    5.549174] i40e 0000:00:06.0: irq 56 for MSI/MSI-X
[    5.579062] i40e 0000:00:06.0: enabling bridge mode: VEB
[    5.615344] i40e 0000:00:06.0: PHC enabled
[    5.636028] i40e 0000:00:06.0: PCI-Express: Speed 8.0GT/s Width x8
[    5.639822] audit: type=1305 audit(1426797692.463:4): audit_pid=345
old=0 auid=4294967295 ses=4294967295
subj=system_u:system_r:auditd_t:s0 res=1
[    5.651225] i40e 0000:00:06.0: Features: PF-id[0] VFs: 128 VSIs:
130 QP: 4 RX: 1BUF RSS FD_ATR FD_SB NTUPLE PTP
[   12.720451] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
[   15.909477] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
[   61.553491] i40e 0000:00:06.0 eth2: NIC Link is Down
[   61.554132] i40e 0000:00:06.0 eth2: the driver failed to link
because an unqualified module was detected.     <<<<<<<<<<<<<<<<<<<<
[   61.555331] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready



With dpdk, see the following output in the VM:

testpmd> stop
Telling cores to stop...
Waiting for lcores to finish...

  ---------------------- Forward statistics for port 0  ----------------------
  RX-packets: 41328971       RX-dropped: 0             RX-total: 41328971
  TX-packets: 0              TX-dropped: 0             TX-total: 0
  ----------------------------------------------------------------------------

  ---------------------- Forward statistics for port 1  ----------------------
  RX-packets: 0              RX-dropped: 0             RX-total: 0
  TX-packets: 41328972       TX-dropped: 0             TX-total: 41328972
  ----------------------------------------------------------------------------

  +++++++++++++++ Accumulated forward statistics for all ports+++++++++++++++
  RX-packets: 41328971       RX-dropped: 0             RX-total: 41328971
  TX-packets: 41328972       TX-dropped: 0             TX-total: 41328972
  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Here it can be seen that one of the ports transmits just fine.  I have
verified that it is not a card,pci port or any such hw issues..

On Thu, Mar 19, 2015 at 4:15 AM, Stefan Assmann <sassmann@redhat.com> wrote:
> On 18.03.2015 23:06, Shannon Nelson wrote:
>> On Wed, Mar 18, 2015 at 3:01 PM, Shannon Nelson
>> <shannon.nelson@intel.com> wrote:
>>>
>>>
>>> On Wed, Mar 18, 2015 at 8:40 AM, jacob jacob <opstkusr@gmail.com> wrote:
>>>>
>>>> On Wed, Mar 18, 2015 at 11:24 AM, Bandan Das <bsd@redhat.com> wrote:
>>>>>
>>>>> Actually, Stefan suggests that support for this card is still sketchy
>>>>> and your best bet is to try out net-next
>>>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
>>>>>
>>>>> Also, could you please post more information about your hardware setup
>>>>> (chipset/processor/firmware version on the card etc) ?
>>>>
>>>> Host CPU : Model name:            Intel(R) Xeon(R) CPU E5-2630 v2 @ 2.60GHz
>>>>
>>>> Manufacturer Part Number:  XL710QDA1BLK
>>>> Ethernet controller: Intel Corporation Ethernet Controller XL710 for
>>>> 40GbE QSFP+ (rev 01)
>>>>  #ethtool -i enp9s0
>>>> driver: i40e
>>>> version: 1.2.6-k
>>>> firmware-version: f4.22 a1.1 n04.24 e800013fd
>>>> bus-info: 0000:09:00.0
>>>> supports-statistics: yes
>>>> supports-test: yes
>>>> supports-eeprom-access: yes
>>>> supports-register-dump: yes
>>>> supports-priv-flags: no
>>>>
>>
>> Jacob,
>>
>> It looks like you're using a NIC with the e800013fd firmware from last
>> summer, and from a separate message that you saw these issues with
>> both the 1.2.2-k and the 1.2.37 version drivers.  I suggest the next
>> step would be to update the NIC firmware as there are some performance
>> and stability updates available that deal with similar issues.  Please
>> see the Intel Networking support webpage at
>> https://downloadcenter.intel.com/download/24769 and look for the
>> NVMUpdatePackage.zip.  This should take care of several of the things
>> Stefan might describe as "sketchy" :-).
>
> Interesting, the following might explain why my XL710 feels a bit
> sketchy then. ;-)
> # ethtool -i p4p1
> driver: i40e
> version: 1.2.37-k
> firmware-version: f4.22.26225 a1.1 n4.24 e12ef
> Looks like the firmware on this NIC is even older.
>
> I tried to update the firmware with nvmupdate64e and the first thing I
> noticed is that you cannot update the firmware even with todays linux
> git. The tool errors out because it cannot access the NVM. Only with a
> recent net-next kernel I was able to update the firmware.
> ethtool -i p4p1
> driver: i40e
> version: 1.2.37-k
> firmware-version: f4.33.31377 a1.2 n4.42 e1932
>
> However during the update I got a lot of errors in dmesg.
> [  301.796664] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0702 received
> [  301.893933] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [  302.005223] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [...]
> [  387.884635] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [  387.896862] i40e 0000:82:00.0: ARQ Overflow Error detected
> [  387.902995] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
> [...]
> [  391.583799] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.714217] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.842656] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  391.973080] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.107586] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.244140] i40e 0000:82:00.0: NVMUpdate write failed err=-53 status=0x0 errno=-16 module=70 offset=0x0 size=2
> [  392.373966] i40e 0000:82:00.0: ARQ Error: Unknown event 0x0703 received
>
> Not sure if that flash was actually successful or not.
>
>   Stefan
