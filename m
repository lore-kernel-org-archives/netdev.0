From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 18 Sep 2017 10:12:48 +0200
Message-ID: <20170918081248.txhars53icbqsvld@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        henrik@austad.us, tglx@linutronix.de
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34250 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752893AbdIRIM4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 04:12:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id k20so4583748wre.1
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 01:12:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
> This patchset is an RFC on a proposal of how the Traffic Control subsystem can
> be used to offload the configuration of traffic shapers into network devices
> that provide support for them in HW. Our goal here is to start upstreaming
> support for features related to the Time-Sensitive Networking (TSN) set of
> standards into the kernel.

Just for the record, here is my score card showing the current status
of TSN support in Linux.  Comments and corrections are more welcome.

Thanks,
Richard


 | FEATURE                                        | STANDARD            | STATUS                       |
 |------------------------------------------------+---------------------+------------------------------|
 | Synchronization                                | 802.1AS-2011        | Implemented in               |
 |                                                |                     | - Linux kernel PHC subsystem |
 |                                                |                     | - linuxptp (userspace)       |
 |------------------------------------------------+---------------------+------------------------------|
 | Forwarding and Queuing Enhancements            | 802.1Q-2014 sec. 34 | RFC posted (this thread)     |
 | for Time-Sensitive Streams (FQTSS)             |                     |                              |
 |------------------------------------------------+---------------------+------------------------------|
 | Stream Reservation Protocol (SRP)              | 802.1Q-2014 sec. 35 | in Open-AVB [1]              |
 |------------------------------------------------+---------------------+------------------------------|
 | Audio Video Transport Protocol (AVTP)          | IEEE 1722-2011      | DNE                          |
 |------------------------------------------------+---------------------+------------------------------|
 | Audio/Video Device Discovery, Enumeration,     | IEEE 1722.1-2013    | jdksavdecc-c [2]             |
 | Connection Management and Control (AVDECC)     |                     |                              |
 | AVDECC Connection Management Protocol (ACMP)   |                     |                              |
 | AVDECC Enumeration and Control Protocol (AECP) |                     |                              |
 | MAC Address Acquisition Protocol (MAAP)        |                     | in Open-AVB                  |
 |------------------------------------------------+---------------------+------------------------------|
 | Frame Preemption                               | P802.1Qbu           | DNE                          |
 | Scheduled Traffic                              | P802.1Qbv           | RFC posted (SO_TXTIME)       |
 | SRP Enhancements and Performance Improvements  | P802.1Qcc           | DNE                          |

 DNE = Does Not Exist (to my knowledge)

1. https://github.com/Avnu/OpenAvnu

   (DISCLAIMER from the website:)

   It is planned to eventually include the various packet encapsulation types,
   protocol discovery daemons, libraries to convert media clocks to AVB clocks
   and vice versa, and drivers.

   This repository does not include all components required to build a full
   production AVB/TSN system (e.g. a turnkey solution to stream stored or live audio
   or video content). Some simple example applications are provided which
   illustrate the flow - but a professional Audio/Video system requires a full media stack
   - including audio and video inputs and outputs, media processing elements, and
   various graphical user interfaces. Various companies provide such integrated
   solutions.

2. https://github.com/jdkoftinoff/jdksavdecc-c
