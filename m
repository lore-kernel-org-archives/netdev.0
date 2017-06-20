From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next 00/12] nfp: add flower app
 with representors
Date: Tue, 20 Jun 2017 12:24:17 -0700
Message-ID: <20170620122417.0c60582e@cakuba.netronome.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33151 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdFTTYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:24:20 -0400
Received: by mail-pg0-f54.google.com with SMTP id f185so66772669pgc.0
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 12:24:20 -0700 (PDT)
In-Reply-To: <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Jun 2017 19:13:43 +0300, Or Gerlitz wrote:
> > Control queues are used to send and receive control messages which are
> > used to communicate configuration information with the firmware. These
> > are in separate vNIC to the queues belonging to the PF netdev. The control
> > queues are not exposed to use-space via a netdev or any other means.  
> 
> Do you have documentation for the control channel or I should look on
> earlier commits?

Hi Or!

We don't have any docs, the ctrl channel was merged in e5c5180a2302
("Merge branch 'nfp-ctrl-vNIC'").  The "control channel" is essentially
a normal data queue which is specially marked as carrying control
messages.

> The control messages you describe here are also the ones that are used
> to load/unload specific app?

No, the app loading, PHY port management and other low-level tasks are
handled by management FW.  The control messages are an application FW
construct.  The control messages are transported by the datapath and
since the datapath is entirely under control of apps the management FW
can't depend on it.  The apps today also completely reload the PCIe
datapath implementation (which is software defined), so we need to use
raw memory mappings to communicate with management FW.

The control messages are mostly used for populating tables and reading
statistics, because those two need to be fast and low overhead.
