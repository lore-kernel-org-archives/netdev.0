From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: Methods to communicate between kernel network stack and user space
Date: Thu, 15 Mar 2012 19:49:40 +0500
Message-ID: <CAAZheX=zq-zgK+svW_K6sRZ6GH-xn_W4C9+MiS_JLwJO84zC6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62439 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030448Ab2COOtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 10:49:42 -0400
Received: by eekc41 with SMTP id c41so1610311eek.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 07:49:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    Consider the figure below:

                                      +-----------------------------------+
                                       |                                    |
                                       |              TRILL  IS-IS<--|---------
                                       |  Quagga protocol  suite  |         |

+-----------------------------------+         |
                      user space
         |

----------------------------------------------------------|----------------------
                      kernel space                                             |

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
                                      |                          |
TRILL    |<-|---
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
