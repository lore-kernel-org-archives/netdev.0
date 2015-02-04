From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v3 17/18] vhost: don't bother copying iovecs in
	handle_rx(), kill memcpy_toiovecend()
Date: Wed, 4 Feb 2015 10:02:27 +0100
Message-ID: <20150204090227.GC9920@redhat.com>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
	<1423032009-18367-17-git-send-email-viro@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1423032009-18367-17-git-send-email-viro@ZenIV.linux.org.uk>
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

>  		if (likely(mergeable) &&
> -		    memcpy_toiovecend(nvq->hdr, (unsigned char *)&headcount,
> -				      offsetof(typeof(hdr), num_buffers),
> -				      sizeof hdr.num_buffers)) {
> +		    copy_to_iter(&headcount, 2, &fixup) != 2) {
>  			vq_err(vq, "Failed num_buffers write");
>  			vhost_discard_vq_desc(vq, headcount);
>  			break;

BTW this will have to be re-based on top of
http://mid.gmane.org/1422896842-19186-1-git-send-email-mst@redhat.com
taking byte-swap into account.
