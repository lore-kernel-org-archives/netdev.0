From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Tue, 14 Jan 2014 13:45:42 -0800
Message-ID: <CANJ5vP+sqZ442ZD7TJ86EMVyfGa1SAuUj0AJnjmE7haNALhFNw@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
	<20140112170939.GA17202@redhat.com>
	<CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
	<20140113094018.GA22726@redhat.com>
	<1389627488.2025.134.camel@bwh-desktop.uk.level5networks.com>
	<CANJ5vPLamPonELhzEEs_e+BQUDrY0w=KpwpzSwGpG551rnbfbQ@mail.gmail.com>
	<CANJ5vPLYJJ1=PVp9LD-4pY2Y9gzk5HROEn_c85pbO4mZkeKA_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vPLYJJ1=PVp9LD-4pY2Y9gzk5HROEn_c85pbO4mZkeKA_g@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

I'd like to confirm the preferred sysfs path structure for mergeable
receive buffers. Is 'mergeable_rx_buffer_size' the right attribute name
to use or is there a strong preference for a different name?

I believe the current approach proposed for the next patchset is to use a
per-netdev attribute group which we will add to the receive
queue kobj (struct netdev_rx_queue). That leaves us with at
least two options:
  (1) Name the attribute group something, e.g., 'virtio-net', in which
      case all virtio-net attributes for eth0 queue N will be of
      the form:
      /sys/class/net/eth0/queues/rx-N/virtio-net/<attribute name>

  (2) Do not name the attribute group (leave the name NULL), in which
      case AFAICT virtio-net and device-independent attributes would be
      mixed without any indication. For example, all virtio-net
      attributes for netdev eth0 queue N would be of the form:
      /sys/class/net/eth0/queues/rx-N/<attribute name>

FWIW, the bonding netdev has a similar sysfs issue and uses a per-netdev
attribute group (stored in the 'sysfs_groups' field of struct netdevice)
In the case of bonding, the attribute group is named, so
device-independent netdev attributes are found in
/sys/class/net/eth0/<attribute name> while bonding attributes are placed
in /sys/class/net/eth0/bonding/<attribute name>.

So it seems like there is some precedent for using an attribute group
name corresponding to the driver name. Does using an attribute group
name of 'virtio-net' sound good or would an empty or different attribute
group name be preferred?

Best,

Mike
