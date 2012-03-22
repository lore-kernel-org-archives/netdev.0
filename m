From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: vhost question
Date: Thu, 22 Mar 2012 09:52:24 +0000
Message-ID: <CAJSP0QXKahPja7S68MC0vLZR7HNxG4hLPRYEFH536QbP1fSu7w@mail.gmail.com>
References: <4F6A84EF.9060105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Steve Glass <stevie.glass@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F6A84EF.9060105@gmail.com>
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

On Thu, Mar 22, 2012 at 1:48 AM, Steve Glass <stevie.glass@gmail.com> wrote:
>
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
>
> Just some further information concerning my earlier question
> concerning vhost and virtio.
>
> I'm using virtio to implement an emulated mac80211 device in the
> guest. A simple network simulation will be used to control delivery of
> frames between guests and for this I am using the vhost approach.
>
> A simple first-cut attempt at the tx and rx kick handlers are given
> below. When the guest transmits frames the vhost's TX kick handler is
> executed and copies the buffers onto a queue for the intended
> recipient(s). When the vhost's RX kick handler is run it copies the
> buffer from the queue and notifies the client that the buffers have
> been used.
>
> The problem is that if there are no frames in the queue when the guest
> rx kick handler runs then it has to exit and I have to arrange that it
> runs again. That's done in the current prototype by having the guests
> poll using a timer - which is ugly and inefficient. Can I get the
> vhost tx kick handler to wake the appropriate vhost rx kick handler?
> How can I achieve this?

Can you queue a tx->rx kick on the vhost work queue with vhost_work_queue()?

Stefan
