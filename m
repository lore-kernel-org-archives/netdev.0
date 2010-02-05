From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port
	numbers
Date: Fri, 5 Feb 2010 08:11:29 +0100
Message-ID: <e2e108261002042311w59ba1372ld9f8fb2f369ca434@mail.gmail.com>
References: <20100203043332.3817.27932.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100203043332.3817.27932.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 3, 2010 at 5:30 AM, Amerigo Wang <amwang@redhat.com> wrote:
>
> This patch introduces /proc/sys/net/ipv4/ip_local_reserved_ports,
> it can be used like ip_local_port_range, but this is used to
> reserve ports for third-party applications which use fixed
> port numbers within ip_local_port_range.
>
> This only affects the applications which call socket functions
> like bind(2) with port number 0, to prevent the kernel getting the ports
> within the specified range for them. For applications which use fixed
> port number, it will have no effects.
>
> Any comments are welcome.

Relying on fixed port numbers is generally considered as a shortcoming
in the application. It would be helpful if you could explain more in
detail why port number reservation is necessary. Maybe there exists
another solution that does not require modifying the bind() system
call.

A quote from the UNIX socket FAQ (http://www.faqs.org/faqs/unix-faq/socket/):

  4.10.  How should I choose a port number for my server?

  The list of registered port assignments can be found in STD 2 or RFC
  1700.  Choose one that isn't already registered, and isn't in
  /etc/services on your system.  It is also a good idea to let users
  customize the port number in case of conflicts with other un-
  registered port numbers in other servers.  The best way of doing this
  is hardcoding a service name, and using getservbyname() to lookup the
  actual port number.  This method allows users to change the port your
  server binds to by simply editing the /etc/services file.

Bart.
