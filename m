From: Park Lee <parklee_sel@yahoo.com>
Subject: Issue on packets sending through ip_route_output_key() to xfrm_lookup() in native IPsec
Date: Thu, 30 Dec 2004 20:51:06 -0800 (PST)
Message-ID: <20041231045106.28169.qmail@web51502.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
  In Linux native IPsec, there is a function
xfrm_lookup(struct dst_entry **dst_p, struct flowi
*fl, struct sock *sk, int flags) (in
/usr/src/linux-2.6.5-1.358/net/xfrm/xfrm_policy.c).
Whenever a packet is sending, kernel will call
xfrm_lookup() to finds/creates a bundle for it. 
  xfrm_lookup() can be called by many functions. one
of these functions is ip_route_output_key(). 
we can see its definition as follows:

int ip_route_output_key(struct rtable **rp, struct
flowi *flp)
{
        int err;
        if ((err = __ip_route_output_key(rp, flp)) !=
0)
                return err;
        return flp->proto ? xfrm_lookup((struct
dst_entry**)rp, flp, NULL, 0) : 0;
}

As ip_route_output_key() calls xfrm_lookup() with the
argument sk set to NULL, Does this means that the
packets sending through ip_route_output_key() to
xfrm_lookup() have no corresponding local socket with
them (because their sk is NULL)? Are these packets all
created by special kernel socket (i.e. icmp_socket and
tcp_socket)? 

Thank you very much.



=====
Best Regards,
Park Lee

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
