From: Radek Pazdera <rpazdera@redhat.com>
Subject: Source-specific multicast socket options documentation
Date: Sat, 30 Jun 2012 00:52:00 +0200
Message-ID: <20120629225200.GA9001@laptop.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man@vger.kernel.org, netdev@vger.kernel.org
To: mtk.manpages@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401Ab2F2Wwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 18:52:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found out, that some source-specific multicast socket options are
missing in the IPv4 manpage (man 7 ip) and I'm trying to write some
documentation for them.

This is what I have now (without the formatting). I'd like to ask,
if you could spare a minute and have just a quick look over it
to make sure there are not some errors (either technical or language -
I'm not native speaker), before I post the patch.

IP_ADD_SOURCE_MEMBERSHIP (since Linux 2.5.68)
    Join a multicast group and allow receiving data only from a specific
    source. Argument is an ip_mreq_source structure.

        struct ip_mreq_source {
            struct in_addr imr_multiaddr;  /* IP multicast group
                                              address */
            struct in_addr imr_interface;  /* IP address of local
                                              interface */
            struct in_addr imr_sourceaddr; /* IP address of
                                              multicast source */
        };

    The ip_mreq_source structure is similar to ip_mreqn structure.
    imr_multiaddr contains the address of the multicast group
    the application wants to join or leave. imr_address is the
    address of the local interface which the system will join
    the multicast group with. imr_sourceaddr is the address of
    multicast source the application wants to receive data
    from.

    Application can use this option multiple times to receive
    data from more than one source.


IP_DROP_SOURCE_MEMBERHSIP (since Linux 2.5.68)
    Leave a source-specific group, i.e. stop receiving data from
    a given multicast group, coming from a given source.

    If the application has subscribed to multiple sources within
    the same group, data from the remaining sources will still
    be delivered. To stop receiving data from all sources at once
    use IP_LEAVE_GROUP.

    Argument is an ip_mreq_source structure as described at
    IP_ADD_SOURCE_MEMBERSHIP.


IP_BLOCK_SOURCE (since Linux 2.5.68)
    Block receiving multicast data from a specific source in a given
    group. This is valid only after the application have subscribed
    to the multicast group using either IP_ADD_MEMBERSHIP or
    IP_ADD_SOURCE_MEMBERSHIP.

    Argument is an ip_mreq_source structure as described at
    IP_ADD_SOURCE_MEMBERSHIP.


IP_UNBLOCK_SOURCE (since Linux 2.5.68)
    Unblock previously blocked multicast source. Returns EADDRNOTAVAIL
    when given source was not being blocked.

    Argument is an ip_mreq_source structure as described at
    IP_ADD_SOURCE_MEMBERSHIP.


IP_MSFILTER (since Linux 2.5.68)
    This option provides access to the advanced full-state filtering API.
    Argument is an ip_msfilter structure.

        struct ip_msfilter {
            struct in_addr imsf_multiaddr; /* IP multicast group
                                              address */
            struct in_addr imsf_interface; /* IP address of local
                                              interface */
            uint32_t       imsf_fmode;     /* Filter-mode */

            uint32_t       imsf_numsrc;    /* Number of sources in
                                              the following array */
            struct in_addr imsf_slist[1];  /* Array of source
                                              addresses */
        };

    There are two macros, MCAST_INCLUDE and MCAST_EXCLUDE, which can be
    used to specify the filtering mode. Additionaly, IP_MSFILTER_SIZE(n)
    macro exists to determine how much memory is needed to store
    ip_msfilter structure with n sources in the source list.

    For full description of multicast source filtering refer to RFC 3376.

My sources for these information were:
    * http://tools.ietf.org/html/rfc3678
    * http://tools.ietf.org/html/rfc3376
    * code (http://lxr.free-electrons.com/source/net/ipv4/ip_sockglue.c)

Thank you!

Radek Pazdera :)
