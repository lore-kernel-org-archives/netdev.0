From: Marcus Meissner <meissner@suse.de>
Subject: af_unix unix_getname: return size for unnamed sockets too small?
Date: Wed, 2 Feb 2011 18:40:15 +0100
Message-ID: <20110202174015.GB25515@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, eric.dumazet@gmail.com, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gorcunov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In net/unix/af_unix.c::unix_getname() there is a small problem:

        if (!u->addr) {
                sunaddr->sun_family = AF_UNIX;
                sunaddr->sun_path[0] = 0;		// not copied out
                *uaddr_len = sizeof(short);
        } else {
                struct unix_address *addr = u->addr;

                *uaddr_len = addr->len;
                memcpy(sunaddr, addr->name, *uaddr_len);
        }

The if (!u->addr) case will not copy out the \0 in the sun_path, as
uaddr_len is just the size of sun_family.

(Shown by socat crashing after decoding gethostname return and expected
sun_path to be a valid string (and not seeing the \0)).

Should it perhaps be *uaddr_len = sizeof(short)+sizeof(char)?

Ciao, Marcus
