From: "David S. Miller" <davem@redhat.com>
Subject: Re: Limit skb to be less than 64K with TSO
Date: Wed, 23 Jul 2003 11:50:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723115032.3f8a95ed.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01022291F4@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@storlinksemi.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E01022291F4@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 11:44:46 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> > I am writing driver + smart NIC's firmware.  The smart NIC 
> > has limited memory. It can do checksum and TSO but with 32K max.
> 
> Do we need a netdev->tso_max so the driver can advertise the maximum TSO
> send support by h/w?

Maybe, it's easy to implement.

Add netdev->tso_max
Add sk->sk_tso_max right after sk->sk_route_caps
When sk->sk_route_caps is set, fetch netdev->tso_max via route
and put into sk->sk_tso_max.
Replace "65535" constant in tcp_sync_mss with sk->sk_tso_max.

That shoule be it.
