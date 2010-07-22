From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Thu, 22 Jul 2010 08:53:39 +0200
Message-ID: <4C47EAF3.3080602@redhat.com>
References: <20100721150732.GR7497@gospo.rdu.redhat.com> <20100721102816.4bef5ada@nehalam> <20100721.103249.107094774.davem@davemloft.net> <201007211129.48288.leedom@chelsio.com> <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Casey Leedom <leedom@chelsio.com>,
	David Miller <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"harald@redhat.com" <harald@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F184620A@orsmsx508.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.07.2010 20:43, Rose, Gregory V wrote:
> I'm curious, what happens when the VM using the VF migrates to a new machine and has another VF assigned to with a different MAC address?
> 
> Intel's view of things is that we don't use persistent MAC addresses in our VFs because the MAC address belongs to the VM and when it migrates it's going to want to use another VF with the same MAC address.  If they're persistent I'm wondering how that can be done.
> 
> This discussion has come about because some folks want to use the VF in the Host VMM.  The original design goal for Intel was that VFs would be assigned to VMs and that VMM vendors would want to assign MAC addresses with their own assigned OUI's.

Using the VF in the host is a feature and I'm sure people will think of
ways to make good use of it. However the actual problem we've seen is a
more practical one. So to pass-through a VF to a VM the host has to be
aware that the VF exists. Therefore you usually have to enable the VF in
the host (i.e. specify the max_vfs parameter). The device will be
discovered by the system and because of the random MAC address udev
ignores the new device. With the additional information we provide with
our solution udev will be able to recognize the device by it's "device
path" and handle it properly (until you decide to pass it to a VM or
just be happy with it in the host).

Remember the issue that lead to the proposal of renaming VFs to vfeth?
That's exactly the problem we try to fix. Additional benefit of an
"address assignment type" as Ben likes to call it would be the handling
of MAC address stealing NICs.

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
