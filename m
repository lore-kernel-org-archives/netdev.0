From: =?iso-8859-1?q?jaganbabu=20rajamanickam?= <jaganbabu_ipv6@yahoo.co.in>
Subject: problem in binding with ipv6 socket.. please help me
Date: Thu, 3 Oct 2002 13:24:45 +0100 (BST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003122445.37447.qmail@web40603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,
 
    Iam working on "Red Hat Linux release 7.2", I have
an interface configured with ipv6 address
"fe80::203:baff:fe14:4747/10". Iam trying to open a
TCP socket on that interface and bind with it, but
bind() call is failing, if iam using getsockopt(
SO_ERROR), iam getting error as "0". What could be the
problem, Is there any configuration need to be done.

  Note: by the way, same programm is running fine for
loopback address (::1) and in_addr_any (::).  can any
one please help me in sorting out this problem.
 Iam pasting my test code below..

Thanx,
Jags

int
ipv6_sock_test(void)
{
   struct sockaddr_in6 laddr, faddr;
   int sock, new_sock, sock_opt;
   int faddrlen;
   char addrbuf[INET6_ADDRSTRLEN];
   int port = 3000;
   /*
    * Set up a socket to listen on for connections.
    * Make sure all sockaddr_in6 fields are zero.
    */
   bzero(&laddr, sizeof (laddr));
   laddr.sin6_family = AF_INET6;
   laddr.sin6_port = htons(port);
   /*laddr.sin6_addr = in6addr_any; structure
assignment */
   laddr.sin6_addr.s6_addr[0] = 0xfe;
   laddr.sin6_addr.s6_addr[1] = 0x80;
   laddr.sin6_addr.s6_addr[2] = 0x0;
   laddr.sin6_addr.s6_addr[3] = 0x0;
   laddr.sin6_addr.s6_addr[4] = 0x0;
   laddr.sin6_addr.s6_addr[5] = 0x0;
   laddr.sin6_addr.s6_addr[6] = 0x0;
   laddr.sin6_addr.s6_addr[7] = 0x0;
   laddr.sin6_addr.s6_addr[8] = 0x2;
   laddr.sin6_addr.s6_addr[9] = 0x3;
   laddr.sin6_addr.s6_addr[10] = 0xba;
   laddr.sin6_addr.s6_addr[11] = 0xff;
   laddr.sin6_addr.s6_addr[12] = 0xfe;
   laddr.sin6_addr.s6_addr[13] = 0x14;
   laddr.sin6_addr.s6_addr[14] = 0x47;
   laddr.sin6_addr.s6_addr[15] = 0x47;

   sock = socket(AF_INET6, SOCK_STREAM, 0);
   if (sock == -1) {
      perror("socket");
      return (-1);
   }
   /* Tell the system to allow local addresses to be
reused. */
   sock_opt = 1;
  if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (void
*)&sock_opt,
     sizeof (sock_opt)) == -1) {
     perror("setsockopt(SO_REUSEADDR)");
     (void) close(sock);
     return (-1);
   }
   if (bind(sock, (struct sockaddr *)&laddr, sizeof
(laddr)) == -1) 

   {
      perror("bind");
      (void) close(sock);
      return (-1);
   }
   return 0;
}

________________________________________________________________________
Missed your favourite TV serial last night? Try the new, Yahoo! TV.
       visit http://in.tv.yahoo.com
