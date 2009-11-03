From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Date: Tue, 3 Nov 2009 13:41:31 +0100
Message-ID: <200911031341.31622.arnd@arndb.de>
References: <cover.1257193660.git.mst@redhat.com> <200911031312.33580.arnd@arndb.de> <20091103123112.GA4961@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
	linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com,
	gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>,
	s.hetze@linux-ag.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091103123112.GA4961@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 November 2009, Michael S. Tsirkin wrote:
> > What was your reason for changing?
> 
> It turns out socket structure is really bound to specific a file, so we
> can not have 2 files referencing the same socket.  Instead, as I say
> above, it's possible to make sendmsg/recvmsg work on tap file directly.

Ah, I see.

> I have implemented this (patch below), but decided to go with the simple
> thing first.  Since no userspace-visible changes are involved, let's do
> this by small steps: it will be easier to figure out when vhost
> is upstream.

This may even make it easier for me to do the same with macvtap
if I resume work on that.

> @@ -416,8 +422,8 @@ int sock_map_fd(struct socket *sock, int flags)
>  
>  static struct socket *sock_from_file(struct file *file, int *err)
>  {
> -       if (file->f_op == &socket_file_ops)
> -               return file->private_data;      /* set in sock_map_fd */
> +       if (file->f_op->get_socket)
> +               return file->f_op->get_socket(file);
>  
>         *err = -ENOTSOCK;

Or maybe do both (socket_file_ops and get_socket), to avoid an indirect
function call.

	Arnd <><
