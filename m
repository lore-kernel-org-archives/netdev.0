From: "Patrick R. McManus" <mcmanus@ducksong.com>
Subject: Re: SIOCETHTOOL ioctl() and a corrupted cmd argument
Date: Wed, 5 Mar 2003 16:32:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305213205.GA1227@ducksong.com>
References: <20030305210047.GA10824@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20030305210047.GA10824@ducksong.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[Patrick R. McManus: Mar 05 16:00]

> as a regular user I get 
> Mar  5 15:46:57 mcmanus kernel: general ioctl cmd 89F0, magic 8946
> 

turns out, as I had expected, my report is bogus.. this ioctl is a
fallback after the siocethtool fails. the driver do_ioctl() never gets
invoked at all when the ioctl() is invoked without being root.

this would be because in net/core/dev.c dev_ioctl() they are filtered out:

        case SIOCETHTOOL:
        case SIOCGMIIPHY:
        case SIOCGMIIREG:
            if (!capable(CAP_NET_ADMIN))
                return -EPERM;

but SIOCETHTOOL shouldn't need perms, right? it has some functionality
that needs it and some that doesn't, and the driver sorts it
out.. there isn't a GIOCETHTOOL at all..

#define ETHTOOL_GSET        0x00000001 /* Get settings. */
#define ETHTOOL_SSET        0x00000002 /* Set settings, privileged. */
