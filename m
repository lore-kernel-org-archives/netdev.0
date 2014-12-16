From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.4 release
Date: Tue, 16 Dec 2014 01:40:41 +0100
Message-ID: <20141216004041.GB11371@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="kORqDWCi7qDJ0mEj"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        nftables 0.4

This release contains a lot of bug fixes and new features contained up
to the recent 3.18 kernel release (and some features coming up in the
yet unreleased 3.19-rc).

New features
============

* Add support for global ruleset operations (available since 3.18).
  Get rid of all tables, chains, and rules in one go:

        # nft flush ruleset

  List the ruleset for all existing families:

        # nft list ruleset

  You can save the ruleset and restore it via:

        # echo "flush ruleset" > ruleset.file
        # nft list ruleset >> ruleset.file
        # nft -f ruleset.file

  This mimics iptables-restore, including the ruleset for all
  supported families: ip, ip6, inet, bridge and arp.

* Full logging support for all the families, including nfnetlink_log
  support (available since 3.17).

* Automatic selection of the optimal set implementation (available
  since 3.16).

  You can tell the kernel to optimize your set representation base
  according to the space-time tradeoff, eg. optimize memory:

        # nft add set filter set1 { type ipv4_addr ; policy memory ; }

  Or optimize performance:

        # nft add set filter set1 { type ipv4_addr ; policy performance ; }

  You can also use this in maps:

        # nft add map filter map1 { type ipv4_addr : verdict ; policy performace ; }

  And indicate the expected size to assist the set selection routine:

        # nft add set filter set1 { type ipv4_addr ; size 1024 ; }

* Complete reject support (available for ip, ip6 and inet since 3.14.
  bridge support and the icmpx abstraction since 3.18).

        # nft add rule filter input reject with icmp type host-unreachable

  and for IPv6:

        # nft add rule ip6 filter input reject with icmpv6 type no-route

  you can the ICMPx abstraction from the inet table:

        # nft add rule inet filter input reject with icmpx type no-route

  and TCP traffic with the reset packets:

        # nft add rule filter input reject with tcp reset

* Masquerading support (available since 3.18).

        # nft add rule nat postrouting masquerade

* Redirect support (available since upcoming Linux kernel 3.19-rc).

        # nft add rule nat prerouting tcp dport 22 redirect to 2222

* Support for NAT flag: random, fully-random, persistent.

* Consistency checks for interferences between updates and ruleset dumps
  (initially available since 3.16, enhanced with ruleset generations
   since 3.18).

* Extend meta to support pkttype, cpu and devgroup matching.

* Automatic regression tests through our customized python shell
  script.

* Allow to disable libreadline and debug at configure stage.

* Full conversion to autotools.

Syntax changes
==============

* 'queue' flags are now expressed as a list of comma-separated symbols:

        # nft add filter input counter queue num 0-3 fanout,bypass

  for consistency with flags, that are always expressed like this.

* nft doesn't resolve names by default anymore. IP addresses are
  always expressed in the numeric representation. A new '-N' option
  allows you to request for the resolution.

Bug fixes
=========

* Crash with anonymous sets with lots of elements.

* Several annoying byteorder issues that resulted in incorrect bytecode
  generation and wrong listings.

* Endianness problems reported from little endian archs.

* Named verdict maps, eg.

        # nft add map filter my_vmap { type ipv4_addr : verdict\; }
        # nft add element filter my_vmap { 1.1.1.1 : drop, 2.2.2.2 : drop}
        # nft add rule filter input ip saddr vmap @my_vmap

* Crash in 'nft describe' with wrong expressions.

* Parsing of ether types.

* Crash on usage of basetypes, eg.

        # nft add rule filter input ct state 8 accept

  instead of 'ct state new'.

* Crash on wrong values when performing basetype parsing, eg.

     <cmdline>:1:29-31: Error: Could not parse conntrack state
     add rule test test ct state xxx accept
                                 ^^^

* Broken listing og meta and ct range expressions, eg.

        nft add rule filter input meta length 33-55 counter

* Don't display a BUG message on too large decimal/hexadecimal values.

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, you libnftnl and libmnl are required:

* http://netfilter.org/projects/libnftnl/index.html

Thanks
======

Thanks to all our contributors, testers and bug reporters, whom have
all helped to get rid of a good bunch of bugs and push new features.

On behalf of the Netfilter Core Team,
Happy bytecode execution :)

--kORqDWCi7qDJ0mEj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-nftables-0.4.txt"

Alvaro Neira (15):
      linealize: generate unary expression with the appropiate operation
      payload: generate dependency in the appropriate byteorder
      src: Enhance payload_gen_dependency()
      datatype: Enhance symbolic_constant_parse()
      nft: complete reject support
      evaluate: fix a crash if we specify ether type or meta nfproto in reject
      delinearize: list the icmpx reason with the string associated
      evaluate: reject: fix crash if we specify ether type or meta nfproto
      evaluate: reject: fix crash if we have transport protocol conflict from inet
      test: update and add the reject tests for ip, ip6, bridge and inet.
      evaluate: reject: accept a reject reason with incorrect network context
      evaluate: reject: check in bridge and inet the network context in reject
      evaluate: reject: check the context in reject without reason for bridge and inet tables
      evaluate: reject: enhance the error support throwing message with more details
      evaluate: reject: fix crash on NULL location with bridge and tcp reset

Alvaro Neira Ayuso (1):
      src: add specific byteorder to the struct proto_hdr_template

Ana Rey (15):
      src: Add support for pkttype in meta expresion
      src: Add support for cpu in meta expresion
      src: meta: Fix the size of cpu attribute
      src: Add devgroup support in meta expresion
      tests: Add automated regression testing
      tests: Add ip folder with test files
      tests: Add ip6 folder with test files.
      tests: Add inet folder with test files.
      tests: Add arp folder with test files.
      tests: Add bridge folder with test files.
      tests: Add any folder with test files.
      tests: regression: Delete all reference to wlan0 in test files
      tests: regression: Delete an unnecessary whitespace in an output messages
      meta: Add support for datatype devgroup
      src: Add cgroup support in meta expresion

Arturo Borrero (18):
      netlink: monitor: add a helper function to handle sets referenced by a rule
      netlink: monitor: fix how rules with intervals are printed
      doc: update documentation with 'monitor' and 'export'
      src: add `flush ruleset'
      netlink: include file and line in netlink ABI errors
      src: add set optimization options
      rule: rename do_command_list_cleanup() to table_cleanup()
      rule: factorize chain and table listing code
      src: add list ruleset command
      src: add nat persistent and random options
      src: add masquerade support
      tests: add tests for masquerade
      mnl: delete useless parameter nf_sock in batch functions
      src: add redirect support
      nft: don't resolve hostnames by default
      tests/regression: masquerade: fix invalid syntax
      tests/regression: redirect: fix invalid syntax
      parser: allow both nat_flags and port specification in redirect

David Kozub (1):
      build: add missing \ in src/Makefile.am (AM_CPPFLAGS)

Eric Leblond (2):
      scanner: fix reading of really long line
      datatype: fix name of icmp* code

Giorgio Dal Molin (2):
      build: add autotools support for the 'doc' subdir
      build: add autotools support for the 'files' subdir

Kevin Fenzi (1):
      doc: nft: Fix trivial error in man page where flush should be rename

Pablo Neira Ayuso (53):
      proto: initialize result expression in ethertype_parse()
      mnl: immediately return on errors in mnl_nft_ruleset_dump()
      mnl: check for NLM_F_DUMP_INTR when dumping object lists
      mnl: add nft_batch_continue() helper
      mnl: add nft_nlmsg_batch_current() helper
      src: rework batching logic to fix possible use of uninitialized pages
      main: propagate error to shell
      mnl: introduce NFT_NLMSG_MAXSIZE
      mnl: fix crashes when using sets with many elements
      src: add level option to the log statement
      src: don't return error in netlink_linearize_rule()
      include: refresh include/linux/nf_tables.h cached copy
      log: netlink_linearize: don't set level if user didn't specify
      src: fix 'describe' command when passing wrong expressions
      mnl: consistency checks across several netlink dumps
      mnl: use nft_batch_begin and nft_batch_end from libnftnl
      src: interpret the event type from the evaluation step
      netlink: use switch whenever possible in the monitor code
      utils: indicate file and line on memory allocation errors
      include: refresh cached copy of nf_tables.h
      build: use PKG_CHECK_MODULES to check for libmnl and libnftnl
      build: use AC_PROG_YACC and AM_PROG_LEX
      rename parser.y to parser_bison.y
      include: add cli.h
      build: autotools conversion
      netlink: don't bug on unknown events
      src: restore nft --debug
      parser: restore named vmap
      tests: regression: any/queue.t: use new syntax
      tests: regression: don't use -nnn for non-list commands
      tests: regression: fix bogus error due to bash
      tests: regression: test masquerade from nat/postrouting too
      datatype: fix crash when using basetype instead of symbolic constants
      datatype: relax datatype check in integer_type_parse()
      netlink_delinearize: clone on netlink_get_register(), release previous on _set()
      meta: set base field on clones
      tests: regression: fix "Listing is broken" instead of output mismatch
      tests: regression: any/ct: remove wrong output
      scanner: don't bug on too large values
      payload: fix endianess issue in payload_expr_pctx_update()
      src: generate set members using integer_type in the appropriate byteorder
      netlink_delinearize: fix listing of set members in host byteorder using integer_type
      netlink: fix listing of range set elements in host byteorder
      rule: fix segmentation faults on kernels without nftables support
      tests: regression: adapt nat tests to use random-fully
      tests: regression: redirect.t: fix bogus errors
      parser: use 'redirect to PORT' instead of 'redirect :PORT'
      tests: regression: fix wrong number of test files
      tests: regression: simplify run_test_file() in case `-e' is used
      tests: regression: log.t: this works for bridge and arp since 3.17
      build: restore --disable-debug
      datatype: missing byteorder in string_type
      Bump version to v0.4

Patrick McHardy (16):
      netlink: check and handle errors from netlink_delinearize_set()
      evaluate: fix concat expressions as map arguments
      payload: take endianess into account when updating the payload context
      datatype: take endianess into account in symbolic_constant_print()
      proto: fix byteorder of ETH_P_* values
      verdict type: handle verdict flags and encoded additional information
      parser: simplify monitor command parsing
      parser: compact log level grammar
      expr: make range_low()/range_high() usable outside of segtree
      queue: clean up queue statement
      parser: rearrange monitor/export rules
      dtype: remove unnecessary icmp* parse/print functions
      stmt: rename nat "random-fully" option to "fully-random"
      meta: properly align types in meta_template table
      dtype: fix memory leak in concat_type_destroy()
      datatype: print datatype name in datatype_print() BUG message

Steven Barth (2):
      build: allow disabling libreadline-support
      build: remove unnecessary libintl.h check

Yanchuan Nian (2):
      Fix memory leak in nft get operation
      Fix typo in chain hook parsing

Yuxuan Shui (1):
      payload: use proto_unknown for raw protocol header


--kORqDWCi7qDJ0mEj--
