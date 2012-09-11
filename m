From: Rick Jones <rick.jones2@hp.com>
Subject: NIC emulation with built-in rate limiting?
Date: Tue, 11 Sep 2012 11:07:07 -0700
Message-ID: <504F7DCB.3050401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>,
	Brian Haley <Brian.Haley@hp.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are there NIC emulations in the kernel with built-in rate limiting?  Or 
is that supposed to be strictly the province of qdiscs/filters?

I've been messing about with netperf in a VM using virtio_net, to which 
rate limiting has been applied to its corresponding vnetN interface - 
rate policing on vnetN ingress (the VM's outbound) and htb on the vnetN 
egress (the VM's inbound).

Looking at the "demo mode" output of netperf and a VM throttled to 800 
Mbit/s in each direction I see that inbound to the VM is quite steady 
over time - right at about 800 Mbit/s.  However, looking at that same 
sort of data for outbound from the VM shows considerable variability 
ranging anywhere from 700 to 900 Mbit/s (though the bulk of the 
variability is clustered more like 750 to 850.

I was thinking that part of the reason may stem from the lack of direct 
feedback to the VM since the policing is on the vnetN interface and 
wondered if it might be "better" if the VM's outbound network rate were 
constrained not by an ingress policing filter on the vnetN interface but 
by the host/hypervisor/emulator portion of the NIC and how quickly it 
pulls packets from the tx queue.  That would allow the queue which 
built-up to be in the VM itself and would more accurately represent what 
a "real NIC" of that bandwidth would do.

happy benchmarking,

rick jones
