From: Colin Ian King <colin.king@canonical.com>
Subject: re: sfc: process RX event inner checksum flags
Date: Fri, 10 Feb 2017 16:14:49 +0000
Message-ID: <61213e24-db1d-8a56-e1a9-e68ae689b73f@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,


not sure if this is a bug, or intentional, but CoverityScan picked up a
mismatch in arguments when calling efx_ef10_handle_rx_event_error() with
commit "sfc: process RX event inner checksum flags" that landed in
linux-next:

  CID 1402067 (#1 of 1): Arguments in wrong order
(SWAPPED_ARGUMENTS)swapped_arguments: The positions of arguments in the
call to efx_ef10_handle_rx_event_errors do not match the ordering of the
parameters:

    rx_l3_class is passed to rx_encap_hdr
    rx_l4_class is passed to rx_l3_class
    rx_encap_hdr is passed to rx_l4_class


The function in question has the prototype:

static u16 efx_ef10_handle_rx_event_errors(struct efx_channel *channel,
                                          unsigned int n_packets,
                                          unsigned int rx_encap_hdr,
                                          unsigned int rx_l3_class,
                                          unsigned int rx_l4_class,
                                          const efx_qword_t *event)

...where as it it being called using:

flags |= efx_ef10_handle_rx_event_errors(channel, n_packets,
rx_l3_class, rx_l4_class, rx_encap_hdr, event);

Is this a bug or intentional?

Colin
