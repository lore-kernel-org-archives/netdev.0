From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sun, 20 Aug 2017 02:58:37 +0530
Message-ID: <CAHgaXd+hccuUYXfTs6gMbvxBctrypofc2FJ10q3QAc0jGsgeyQ@mail.gmail.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
 <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com> <CAHgaXdJnHxu4gJ8ZVFmrmaXyZL1oFkTbz2K___xKLQedTLmBQg@mail.gmail.com>
 <9d77730f-c6a8-b337-599e-5919207a7e0a@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>, Andrew Lunn <andrew@lunn.ch>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9d77730f-c6a8-b337-599e-5919207a7e0a@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are numbers.

Without any JIT enabled

test_pkt_access:PASS:ipv4 1823 nsec
test_pkt_access:PASS:ipv6 1743 nsec
test_xdp:PASS:ipv4 769022 nsec
test_xdp:PASS:ipv6 15408 nsec
test_l4lb:PASS:ipv4 12441 nsec
test_l4lb:PASS:ipv6 18131 nsec
test_tcp_estats:PASS: 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-prog-id 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-map-id 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total prog id found by get_next_id 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total map id found by get_next_id 0 nsec
test_pkt_md_access:PASS: 5816 nsec
Summary: 30 PASSED, 0 FAILED

With only bpf_jit_enable

test_pkt_access:PASS:ipv4 263 nsec
test_pkt_access:PASS:ipv6 337 nsec
test_xdp:PASS:ipv4 1377212 nsec
test_xdp:PASS:ipv6 1290381 nsec
test_l4lb:PASS:ipv4 2689 nsec
test_l4lb:PASS:ipv6 3804 nsec
test_tcp_estats:PASS: 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-prog-id 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-map-id 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total prog id found by get_next_id 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total map id found by get_next_id 0 nsec
test_pkt_md_access:PASS: 41609 nsec
Summary: 30 PASSED, 0 FAILED


With bpf_jit_enable and bpf_jit_harden set

test_pkt_access:PASS:ipv4 416 nsec
test_pkt_access:PASS:ipv6 509 nsec
test_xdp:PASS:ipv4 1512428 nsec
test_xdp:PASS:ipv6 962318 nsec
test_l4lb:PASS:ipv4 4135 nsec
test_l4lb:PASS:ipv6 5497 nsec
test_tcp_estats:PASS: 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-prog-id 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-map-id 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total prog id found by get_next_id 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total map id found by get_next_id 0 nsec
test_pkt_md_access:PASS: 24774 nsec
Summary: 30 PASSED, 0 FAILED

-Shubham
