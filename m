From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Wed, 12 Mar 2014 13:58:57 -0700
Message-ID: <CAHA+R7OrNoa7_J-rOskxgdvkM5gAnQyoFBeCXSziY7XMd-yLNA@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
	<1394657163-7472-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tj@kernel.org,
	ssorce@redhat.com, jkaluza@redhat.com, lpoetter@redhat.com,
	kay@redhat.com
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 1:46 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> @@ -1098,6 +1135,16 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
>         if (newsk == NULL)
>                 goto out;
>
> +       err = init_peercgroup(newsk);
> +       if (err)
> +               goto out;
> +
> +       err = alloc_cgroup_path(sk);
> +       if (err)
> +               goto out;
> +
> +       err = -ENOMEM;
> +

Don't we need to free the cgroup_path on error path
in this function?
