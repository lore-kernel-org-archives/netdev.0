From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: macvtap performance regression (bisected) between 3.13 and 3.14-rc1
Date: Thu, 27 Feb 2014 21:52:22 +0100
Message-ID: <530FA586.3010400@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	KVM list <kvm@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad,

commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
    macvtap: Add support of packet capture on macvtap device.

causes a performance regression for iperf traffic between two KVM guests
on my s390 system. Both guests are connected via two macvtaps on the same OSA
network card.
Before that patch I get ~20 Gbit/sec between two guests, afterwards I get
~4Gbit/sec

Latency seems to be unchanges (uperf 1byte ping pong).

According to ifconfig in the guest, I have ~ 1500 bytes per packet with this
patch and ~  40000 bytes without. So for some reason this patch causes the
network stack to do segmentation. (the guest kernel stays the same, only host 
kernel is changed).

Any ideas?


Christian
