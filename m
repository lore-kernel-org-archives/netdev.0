From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: Methods to communicate between kernel network stack and user space
Date: Thu, 15 Mar 2012 20:00:05 +0500
Message-ID: <CAAZheX=0v2AK0aDN0ZE=6n13JF27Nd-jOyi7GPzSSc4cYpnkeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:65460 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030379Ab2COPAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 11:00:09 -0400
Received: by vcqp1 with SMTP id p1so3223588vcq.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 08:00:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
   Consider the figure below:

                                     +-----------------------------------+
                                      |                                    |
                                      |              TRILL  IS-IS<--|---------
                                      |  Quagga protocol  suite  |         |

+-----------------------------------+         |
       user space                                                              |
         ---------------------------------------------------------------------------|-----
       kernel space                                                           |

             |

+------------------------------------------+   |
                                     |         TCP / UDP / ICMP      |   |
                                     |
          |   |

+------------------------------------------+   |
                                     |               IPv4 /IPv6
     |   |
                                     |
          |   |

+------------------------------------------+  |
                                     |
+-------------+  |   |
                                     |                         |TRILL
  |<--|---
                                     |           Bridging   +------------+  |

+------------------------------------------+
                                     |    Interface between Device    |
                                     |Driver and network stack(dev.c)|

+------------------------------------------+
                                     |            Device Driver            |
                                     |
          |
                                     +-----------------|
|------------------+
                                                        |     |
                                                         NIC


                      As you may know, TRILL uses IS-IS protocol to
calculate pairwise optimal paths and other control plane parameters.
Now i want to communicate between TRILL forwarding in bridging with
TRILL IS-IS in quagga protocol suite to send and receive control plane
packets. I don't know what method should i use for this kind of
communication.

Netlink sockets are appropriate for this purpose?
Or please suggest something else.

Thanks in Advance...!!
