From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Wed, 9 Jun 2004 22:45:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF72A3CA91.7584BEA0-ON88256EAF.001F34CA-88256EAF.001F8BE8@us.ibm.com>
References: <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrew Morton <akpm@osdl.org>, David Dillow <dave@thedillows.org>,
        Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
To: David Stevens <dlstevens@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

PS - Here's a trivial program that will join a group. If you run this on
one side, then a ping to the multicast address will work when it's in
the group, and stop answering when it exits. There are more general
things that have been around for years for testing-- I just threw this
together just now. (I hope it doesn't have any bugs! :-) ) Should be
suitable for testing hardware multicast address filters...

                                        +-DLS

#include <stdio.h>

#include <netinet/in.h>

int
main(int argc, char *argv[])
{
        struct ip_mreqn mreqn;
        int s;

        if (argc != 3) {
                fprintf(stderr, "usage: %s <dev> <group>\n", argv[0]);
                exit(1);
        }
        s = socket(PF_INET, SOCK_DGRAM, 0);
        if (s < 0) {
                perror("socket");
                exit(1);
        }
        memset(&mreqn, 0, sizeof(mreqn));
        mreqn.imr_ifindex = if_nametoindex(argv[1]);
        if (!mreqn.imr_ifindex) {
                fprintf(stderr, "%s: \"%s\" invalid interface\n", argv[0],
                        argv[1]);
                exit(1);
        }
        if (inet_pton(AF_INET, argv[2], &mreqn.imr_multiaddr) <= 0) {
                fprintf(stderr, "%s: \"%s\" invalid group address\n", 
argv[0],
                        argv[2]);
                exit(1);
        }
        if (setsockopt(s, SOL_IP, IP_ADD_MEMBERSHIP, &mreqn,sizeof mreqn) 
< 0) {
                perror("IP_ADD_MEMBERSHIP");
                exit(1);
        }
        printf("joined group %s on %s (pausing...)");
        fflush(stdout);
        pause();
        exit(0);
}
