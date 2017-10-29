From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 2/2] chcr: Add support for Inline IPSec
Date: Sun, 29 Oct 2017 14:00:30 +0800
Message-ID: <201710291300.AUgeQoSM%fengguang.wu@intel.com>
References: <1509124098-12234-2-git-send-email-atul.gupta@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org, Harsh Jain <harsh@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: Atul Gupta <atul.gupta@chelsio.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1509124098-12234-2-git-send-email-atul.gupta@chelsio.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Atul,

Thank you for the patch! Yet we hit a small issue.
[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Atul-Gupta/cxgb4-Add-support-for-Inline-IPSec-Tx/20171029-060344
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +1678 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h

f2b7e78db drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-12-10  1562  
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1563  void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1564  			 const u8 *addr);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1565  int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1566  		      u64 mask0, u64 mask1, unsigned int crc, bool enable);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1567  
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1568  int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1569  		enum dev_master master, enum dev_state *state);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1570  int t4_fw_bye(struct adapter *adap, unsigned int mbox);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1571  int t4_early_init(struct adapter *adap, unsigned int mbox);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1572  int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset);
636f9d371 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-09-26  1573  int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
636f9d371 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-09-26  1574  			  unsigned int cache_line_size);
636f9d371 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-09-26  1575  int t4_fw_initialize(struct adapter *adap, unsigned int mbox);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1576  int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1577  		    unsigned int vf, unsigned int nparams, const u32 *params,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1578  		    u32 *val);
8f46d4671 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Arjun Vynipadath     2017-06-23  1579  int t4_query_params_ns(struct adapter *adap, unsigned int mbox, unsigned int pf,
8f46d4671 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Arjun Vynipadath     2017-06-23  1580  		       unsigned int vf, unsigned int nparams, const u32 *params,
8f46d4671 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Arjun Vynipadath     2017-06-23  1581  		       u32 *val);
01b696141 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-22  1582  int t4_query_params_rw(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1583  		       unsigned int vf, unsigned int nparams, const u32 *params,
8f46d4671 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Arjun Vynipadath     2017-06-23  1584  		       u32 *val, int rw, bool sleep_ok);
01b696141 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-22  1585  int t4_set_params_timeout(struct adapter *adap, unsigned int mbox,
688848b14 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Anish Bhatt          2014-06-19  1586  			  unsigned int pf, unsigned int vf,
688848b14 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Anish Bhatt          2014-06-19  1587  			  unsigned int nparams, const u32 *params,
01b696141 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-22  1588  			  const u32 *val, int timeout);
01b696141 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-22  1589  int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
01b696141 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-22  1590  		  unsigned int vf, unsigned int nparams, const u32 *params,
688848b14 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Anish Bhatt          2014-06-19  1591  		  const u32 *val);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1592  int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1593  		unsigned int vf, unsigned int txq, unsigned int txq_eth_ctrl,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1594  		unsigned int rxqi, unsigned int rxq, unsigned int tc,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1595  		unsigned int vi, unsigned int cmask, unsigned int pmask,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1596  		unsigned int nexact, unsigned int rcaps, unsigned int wxcaps);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1597  int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1598  		unsigned int pf, unsigned int vf, unsigned int nmac, u8 *mac,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1599  		unsigned int *rss_size);
4f3a0fcfb drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-06-05  1600  int t4_free_vi(struct adapter *adap, unsigned int mbox,
4f3a0fcfb drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-06-05  1601  	       unsigned int pf, unsigned int vf,
4f3a0fcfb drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-06-05  1602  	       unsigned int viid);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1603  int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
f8f5aafa9 drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-05-10  1604  		int mtu, int promisc, int all_multi, int bcast, int vlanex,
f8f5aafa9 drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-05-10  1605  		bool sleep_ok);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1606  int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1607  		      unsigned int viid, bool free, unsigned int naddr,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1608  		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok);
fc08a01a6 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-02-16  1609  int t4_free_mac_filt(struct adapter *adap, unsigned int mbox,
fc08a01a6 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-02-16  1610  		     unsigned int viid, unsigned int naddr,
fc08a01a6 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-02-16  1611  		     const u8 **addr, bool sleep_ok);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1612  int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1613  		  int idx, const u8 *addr, bool persist, bool add_smt);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1614  int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1615  		     bool ucast, u64 vec, bool sleep_ok);
688848b14 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Anish Bhatt          2014-06-19  1616  int t4_enable_vi_params(struct adapter *adap, unsigned int mbox,
688848b14 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Anish Bhatt          2014-06-19  1617  			unsigned int viid, bool rx_en, bool tx_en, bool dcb_en);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1618  int t4_enable_vi(struct adapter *adap, unsigned int mbox, unsigned int viid,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1619  		 bool rx_en, bool tx_en);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1620  int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1621  		     unsigned int nblinks);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1622  int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1623  	       unsigned int mmd, unsigned int reg, u16 *valp);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1624  int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1625  	       unsigned int mmd, unsigned int reg, u16 val);
ebf4dc2b1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-04-11  1626  int t4_iq_stop(struct adapter *adap, unsigned int mbox, unsigned int pf,
ebf4dc2b1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-04-11  1627  	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
ebf4dc2b1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-04-11  1628  	       unsigned int fl0id, unsigned int fl1id);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1629  int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1630  	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1631  	       unsigned int fl0id, unsigned int fl1id);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1632  int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1633  		   unsigned int vf, unsigned int eqid);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1634  int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1635  		    unsigned int vf, unsigned int eqid);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1636  int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1637  		    unsigned int vf, unsigned int eqid);
5d700ecb0 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-06-05  1638  int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox);
23853a0a9 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-04-26  1639  void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl);
2061ec3f1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Ganesh Goudar        2017-05-19  1640  int t4_update_port_info(struct port_info *pi);
c3168cabe drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Ganesh Goudar        2017-08-20  1641  int t4_get_link_params(struct port_info *pi, unsigned int *link_okp,
c3168cabe drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Ganesh Goudar        2017-08-20  1642  		       unsigned int *speedp, unsigned int *mtup);
625ba2c2e drivers/net/cxgb4/cxgb4.h                  Dimitris Michailidis 2010-04-01  1643  int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
881806bc1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-05-18  1644  void t4_db_full(struct adapter *adapter);
881806bc1 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-05-18  1645  void t4_db_dropped(struct adapter *adapter);
8e3d04fd7 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-08-13  1646  int t4_set_trace_filter(struct adapter *adapter, const struct trace_params *tp,
8e3d04fd7 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-08-13  1647  			int filter_index, int enable);
8e3d04fd7 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-08-13  1648  void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
8e3d04fd7 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-08-13  1649  			 int filter_index, int *enabled);
8caa1e844 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-05-18  1650  int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
8caa1e844 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Vipul Pandya         2012-05-18  1651  			 u32 addr, u32 val);
b72a32dac drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2016-08-22  1652  int t4_sched_params(struct adapter *adapter, int type, int level, int mode,
b72a32dac drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2016-08-22  1653  		    int rateunit, int ratemode, int channel, int class,
b72a32dac drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2016-08-22  1654  		    int minrate, int maxrate, int weight, int pktsize);
68bce1922 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Kumar Sanghvi        2014-03-13  1655  void t4_sge_decode_idma_state(struct adapter *adapter, int state);
a3bfb6179 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-05  1656  void t4_idma_monitor_init(struct adapter *adapter,
a3bfb6179 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-05  1657  			  struct sge_idma_monitor_state *idma);
a3bfb6179 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-05  1658  void t4_idma_monitor(struct adapter *adapter,
a3bfb6179 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-05  1659  		     struct sge_idma_monitor_state *idma,
a3bfb6179 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2015-05-05  1660  		     int hz, int ticks);
858aa65c5 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-08-11  1661  int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
858aa65c5 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-08-11  1662  		      unsigned int naddr, u8 *addr);
5ccf9d049 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1663  void t4_tp_pio_read(struct adapter *adap, u32 *buff, u32 nregs,
5ccf9d049 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1664  		    u32 start_index, bool sleep_ok);
4359cf336 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1665  void t4_tp_tm_pio_read(struct adapter *adap, u32 *buff, u32 nregs,
4359cf336 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1666  		       u32 start_index, bool sleep_ok);
5ccf9d049 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1667  void t4_tp_mib_read(struct adapter *adap, u32 *buff, u32 nregs,
5ccf9d049 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1668  		    u32 start_index, bool sleep_ok);
5ccf9d049 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Rahul Lakkireddy     2017-10-13  1669  
0fbc81b3a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-09-17  1670  void t4_uld_mem_free(struct adapter *adap);
0fbc81b3a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-09-17  1671  int t4_uld_mem_alloc(struct adapter *adap);
0fbc81b3a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-09-17  1672  void t4_uld_clean_up(struct adapter *adap);
0fbc81b3a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-09-17  1673  void t4_register_netevent_notifier(void);
94cdb8bb9 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-08-17  1674  void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
ab677ff4a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-11-18  1675  void free_tx_desc(struct adapter *adap, struct sge_txq *q,
ab677ff4a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-11-18  1676  		  unsigned int n, bool unmap);
ab677ff4a drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Hariprasad Shenai    2016-11-18  1677  void free_txq(struct adapter *adap, struct sge_txq *q);
fecc6d8b4 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h Atul Gupta           2017-10-27 @1678  inline void cxgb4_reclaim_completed_tx(struct adapter *adap,

:::::: The code at line 1678 was first introduced by commit
:::::: fecc6d8b46e45fab51454b2d09c2a763ce8b5aad cxgb4: Add support for Inline IPSec Tx

:::::: TO: Atul Gupta <atul.gupta@chelsio.com>
:::::: CC: 0day robot <fengguang.wu@intel.com>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
