From: "w.szukalski" <szukw000@students.uni-mainz.de>
Subject: linux-2.4.21 and IPv6: problem solved
Date: Sun, 17 Aug 2003 15:27:25 GMT
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817152725.A2212@keun>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First I regret: I did not mention the socket creation:

	reader = socket(AF_INET6, SOCK_DGRAM, PF_UNSPEC);
	writer = socket(AF_INET6, SOCK_DGRAM, PF_UNSPEC);

In the meantime I inserted some 'printk(KERN_DEBUG "")' into the
kernel code.

Test program without connect():

linux/net/ipv6/af_inet6.c, inet6_bind():

        /* Binding to link-local address requires an interface */
        if (sk->bound_dev_if == 0) {
            release_sock(sk);
printk(KERN_DEBUG "%s:%d:link-local address without IF:EINVAL\n", 
__FILE__,__LINE__);
            return -EINVAL;
        }
After setting for 'ff02::1':
	read6.sin6_scope_id = 2;

the reader succeeded.

Test program with connect():

linux/net/ipv6/udp.c, udpv6_connect():
	
        /* Connect to link-local address requires an interface */
        if (sk->bound_dev_if == 0)
  {
printk(KERN_DEBUG "%s:%d:sk->bound_dev_if == 0:EINVAL\n", 
__FILE__,__LINE__);
            return -EINVAL;
  }

After setting for 'ff02::1':
	write6.sin6_scope_id = 2;

the writer succeeded.


winfried
