From: Gerd Hoffmann <kraxel@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: Introduce VM Sockets
Date: Thu, 14 Feb 2013 12:05:53 +0100
Message-ID: <511CC511.7080902@redhat.com>
References: <1360196636-9357-1-git-send-email-acking@vmware.com>
	<1360196636-9357-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net
To: Andy King <acking@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1360196636-9357-2-git-send-email-acking@vmware.com>
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

On 02/07/13 01:23, Andy King wrote:
> +		written = transport->stream_enqueue(
> +				vsk, msg->msg_iov,
> +				len - total_written);

Hmm, shouldn't we pass total_written to stream_enqueue here?

In case a blocking send(big-buffer) call gets splitted into multiple
stream_enqueue calls the second (and further) stream_enqueue calls need
to know at which msg offset they should continue sending the data, no?

cheers,
  Gerd
