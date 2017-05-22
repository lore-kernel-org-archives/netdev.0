From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 22 May 2017 13:43:00 +1000
Message-ID: <20170522134300.0bfd175a@canb.auug.org.au>
References: <20170522111605.14f93676@canb.auug.org.au>
        <20170521.231410.1999783448679718181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, mlichvar@redhat.com,
        willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170521.231410.1999783448679718181.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Sun, 21 May 2017 23:14:10 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 22 May 2017 11:16:05 +1000
> 
> > After merging the net-next tree, today's linux-next build (powerpc
> > ppc64_defconfig) failed like this:
> > 
> > net/socket.c: In function 'put_ts_pktinfo':
> > net/socket.c:695:28: error: 'SCM_TIMESTAMPING_PKTINFO' undeclared (first use in this function)
> >   put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
> >                             ^
> > Caused by commit
> > 
> >   aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
> > 
> > This probably broke every architecture that has its own
> > arch/<arch>/include/uapi/asm/socket.h that does not include
> > include/uapi/asm-generic/socket.h :-(
> > 
> > I have used the net-next tree from next-20170519 for today.  
> 
> I've just pushed the following, thanks for the report:

Looks good except:

> diff --git a/arch/parisc/include/uapi/asm/socket.h b/arch/parisc/include/uapi/asm/socket.h
> index 5147018..784b871 100644
> --- a/arch/parisc/include/uapi/asm/socket.h
> +++ b/arch/parisc/include/uapi/asm/socket.h
> @@ -97,4 +97,6 @@
>  
>  #define SO_COOKIE		0x4032
>  
> +#define SCM_TIMESTAMPING_PKTINFO	58

Does this need to be 0x4033 (or something)?

-- 
Cheers,
Stephen Rothwell
