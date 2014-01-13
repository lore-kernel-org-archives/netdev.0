From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Mon, 13 Jan 2014 11:07:29 -0800
Message-ID: <CANJ5vPLamPonELhzEEs_e+BQUDrY0w=KpwpzSwGpG551rnbfbQ@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
	<52CCF177.7020500@redhat.com> <20140108192109.GC18312@redhat.com>
	<CANJ5vP+Qxa5j_Cp1FBK-qdO+U+dy2kiY5N2bmWdMKbCoY9EwDQ@mail.gmail.com>
	<20140112170939.GA17202@redhat.com>
	<CANJ5vP+Vu8=haCetZkcefPgR8pGe0iDZ03EZhJHLSgunCaHJsQ@mail.gmail.com>
	<20140113094018.GA22726@redhat.com>
	<1389627488.2025.134.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389627488.2025.134.camel@bwh-desktop.uk.level5networks.com>
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

On Mon, Jan 13, 2014 at 7:38 AM, Ben Hutchings <bhutchings@solarflare.com>
wrote:
> I don't think RPS should own this structure.  It's just that there are
> currently no per-RX-queue attributes other than those defined by RPS.

Agreed, there is useful attribute-independent functionality already
built around netdev_rx_queue - e.g., dynamically resizing the rx queue
kobjs as the number of RX queues enabled for the netdev is changed. While
the current attributes happen to be used only by RPS, AFAICT it seems
RPS should not own netdev_rx_queue but rather should own the RPS-specific
fields themselves within netdev_rx_queue.

If there are no objections, it seems like I could modify
netdev_rx_queue and related functionality so that their existence does
not depend on CONFIG_RPS, and instead just have CONFIG_RPS control
whether or not the RPS-specific attributes/fields are present.

Best,

Mike
